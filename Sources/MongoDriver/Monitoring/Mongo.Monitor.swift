import Atomics
import BSON
import Durations
import Heartbeats
import MongoChannel
import MongoTopology
import MongoWire
import NIOCore

extension Mongo
{
    /// A deployment topology monitor.
    public final
    actor Monitor
    {
        public nonisolated
        let heartbeatInterval:Milliseconds
        public nonisolated
        let bootstrap:DriverBootstrap
        public nonisolated
        let cluster:Cluster

        private
        var topology:MongoTopology
        private
        var tasks:Tasks
        
        init(bootstrap:DriverBootstrap)
        {
            self.heartbeatInterval = 1000
            self.bootstrap = bootstrap
            self.cluster = .init()

            self.topology = .terminated
            self.tasks = .init()
        }

        deinit
        {
            // let _:ClusterTime? = self._clusterTime.destroy()?.takeRetainedValue()
        }
    }
}
extension Mongo.Monitor
{
    // TODO: we don’t need to traffic the allocated object outside of this setter
    // nonisolated public
    // var clusterTime:Mongo.ClusterTime?
    // {
    //     get
    //     {
    //         self._clusterTime.load(ordering: .relaxed)?.takeUnretainedValue()
    //     }
    //     set(value)
    //     {
    //         guard let value:Mongo.ClusterTime
    //         else
    //         {
    //             return
    //         }

    //         let owned:Unmanaged<Mongo.ClusterTime> = .passRetained(value)
    //         var shared:Unmanaged<Mongo.ClusterTime>? = self._clusterTime.load(
    //             ordering: .relaxed)
            
    //         while true
    //         {
    //             if  let old:Mongo.ClusterTime = shared?.takeUnretainedValue(),
    //                     old.max.timestamp >= value.max.timestamp
    //             {
    //                 owned.release()
    //                 return
    //             }

    //             switch self._clusterTime.weakCompareExchange(expected: shared, desired: owned,
    //                 successOrdering: .acquiringAndReleasing,
    //                 failureOrdering: .acquiring)
    //             {
    //             case (exchanged: false, let current):
    //                 shared = current
                
    //             case (exchanged: true, let owned?):
    //                 owned.release()
    //                 return
                
    //             case (exchanged: true, nil):
    //                 return
    //             }
    //         }
    //     }
    // }
}
extension Mongo.Monitor
{
    func seed(with seeds:Set<MongoTopology.Host>)
    {
        guard case .terminated = self.topology
        else
        {
            fatalError("cannot reseed deployment that is not in a `terminated` state")
        }

        self.topology = .unknown(.init(hosts: seeds))
        for host:MongoTopology.Host in seeds
        {
            guard case _? = self.monitor(host)
            else
            {
                fatalError("cannot reseed deployment that is currently terminating")
            }
        }
    }
    func unseed() async
    {
        guard case nil = self.tasks.promise
        else
        {
            fatalError("cannot terminate monitoring tasks that are already being terminated")
        }

        self.topology.terminate()

        guard self.tasks.count != 0
        else
        {
            return
        }
        await withCheckedContinuation
        {
            self.tasks.promise = $0
        }
    }

    private
    func snapshot() -> MongoTopology.Servers
    {
        self.topology.snapshot(heartbeatInterval: self.heartbeatInterval)
    }

    private
    func clear(host:MongoTopology.Host, status:(any Error)?) async -> Bool
    {
        let monitor:Bool = self.topology.clear(host: host, status: status)
        await self.cluster.push(snapshot: self.snapshot())
        return monitor
    }
    private
    func update(host:MongoTopology.Host, with update:MongoTopology.Update,
        sessions:Mongo.LogicalSessions) async -> Bool
    {
        let monitor:Bool = self.topology.update(host: host, with: update)
        { 
            let _:Task<Void, Never>? = self.monitor($0) 
        }

        await self.cluster.push(snapshot: self.snapshot(), sessions: sessions)
        
        return monitor
    }
}
extension Mongo.Monitor
{
    private
    func monitor(_ host:MongoTopology.Host) -> Task<Void, Never>?
    {
        self.tasks.retain { await self.monitor(host) }
    }
    private
    func monitor(_ host:MongoTopology.Host) async
    {
        defer
        {
            self.tasks.release()
        }
        while true
        {
            // do not spam connections more than once per second
            async
            let cooldown:Void = try await Task.sleep(for: .seconds(1))
            let status:(any Error)?
            
            do
            {
                try await self.connect(to: host)
                status = nil
            }
            catch let error
            {
                status = error
            }

            if await self.clear(host: host, status: status)
            {
                try? await cooldown
            }
            else
            {
                //  host was removed.
                break
            }
        }
    }
    private
    func connect(to host:MongoTopology.Host) async throws
    {
        let heartbeat:Heartbeat = .init(interval: .milliseconds(self.heartbeatInterval))
        let channel:MongoChannel = try await self.bootstrap.channel(to: host,
            attaching: heartbeat.heart)
        
        defer
        {
            // will be a no-op if the channel closed spontaneously,
            // terminating the stream of heartbeats
            channel.close()
        }

        let _pool:MongoChannel = try await self.bootstrap.channel(to: host,
            attaching: heartbeat.heart)
        
        defer
        {
            _pool.close()
        }

        async
        let authentication:Mongo.HelloResponse = _pool.establish(
            credentials: self.bootstrap.credentials,
            appname: self.bootstrap.appname)

        //  initial login, performs auth (if using auth).
        let initial:Mongo.HelloResponse = try await channel.establish(
            credentials: self.bootstrap.credentials,
            appname: self.bootstrap.appname)
        
        let _:Mongo.HelloResponse = try await authentication

        guard await self.update(host: host, with: .init(
                    variant: initial.variant, 
                    channel: _pool),
                sessions: initial.sessions)
        else
        {
            return
        }

        for try await _:Void in heartbeat
        {
            let updated:Mongo.HelloResponse = try await channel.run(
                hello: .init(user: nil))
            if  updated.token != initial.token
            {
                throw MongoChannel.TokenError.init(recorded: initial.token,
                    invalid: updated.token)
            }
            guard await self.update(host: host, with: .init(
                        variant: updated.variant, 
                        channel: _pool),
                    sessions: updated.sessions)
            else
            {
                break
            }
        }
    }
}
extension Mongo.Monitor
{
    /// Attempts to obtain a channel to a cluster member matching the given
    /// instance selector, and if successful, generates and attaches a ``Session/ID``
    /// to it that the driver believes is not currently in use.
    ///
    /// Because the session identifier is random and generated locally, there
    /// is a (small) chance that it may collide with a session identifier
    /// generated by another driver, a concurrently-seeded session pool, or a
    /// previous application run, if the application exited abnormally.
    ///
    /// UUID collisions are exceedingly rare, and the topology monitor always
    /// attempts to clear sessions it generated on shutdown, so this is an
    /// extremely unlikely scenario.
    ///
    /// The driver will attempt to re-use session identifiers that are no
    /// longer in use if it believes the server has not yet released the
    /// session descriptor on its end, to minimize the number of active server
    /// sessions at a given time.
}
