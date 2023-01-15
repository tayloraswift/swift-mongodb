import Atomics
import BSON
import Durations
import Heartbeats
import MongoChannel
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
        var topology:Mongo.Topology<ConnectionPool>
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
    func seed(with seeds:Set<Mongo.Host>)
    {
        guard case .terminated = self.topology
        else
        {
            fatalError("cannot reseed deployment that is not in a `terminated` state")
        }

        self.topology = .unknown(.init(hosts: seeds))
        for host:Mongo.Host in seeds
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

        self.topology.removeAll()

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
    func snapshot() -> Mongo.Servers
    {
        .init(from: self.topology, heartbeatInterval: self.heartbeatInterval)
    }

    private
    func sequence(error status:(any Error)?, host:Mongo.Host) async -> ExitStatus
    {
        let monitor:Bool = self.topology.combine(error: status, host: host)
        await self.cluster.push(snapshot: self.snapshot())
        return monitor ? .reconnect : .stop
    }
    private
    func sequence(update:Mongo.TopologyUpdate?,
        sessions:Mongo.LogicalSessions,
        pool:Mongo.ConnectionPool,
        host:Mongo.Host) async -> Bool
    {
        let monitor:Bool = self.topology.combine(update: update, host: host, pool: pool)
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
    func monitor(_ host:Mongo.Host) -> Task<Void, Never>?
    {
        self.tasks.retain { await self.monitor(host) }
    }
    private
    func monitor(_ host:Mongo.Host) async
    {
        defer
        {
            self.tasks.release()
        }
        for generation:UInt in 0...
        {
            // do not spam connections more than once per second
            async
            let cooldown:Void? = try? Task.sleep(for: .seconds(1))

            switch await self.pool(generation: generation, host: host)
            {
            case .reconnect:
                await cooldown
                continue
            
            case .stop:
                return
            }
        }
    }
    private
    func pool(generation:UInt, host:Mongo.Host) async -> ExitStatus
    {
        let heartbeat:Heartbeat = .init(interval: .milliseconds(self.heartbeatInterval))
        let channel:MongoChannel
        do
        {
            channel = try await self.bootstrap.channel(to: host, attaching: heartbeat.heart)
        }
        catch let error
        {
            return await self.sequence(error: error, host: host)
        }

        let helloResponse:Mongo.HelloResponse

        switch await channel.establish(
            credentials: self.bootstrap.credentials,
            appname: self.bootstrap.appname)
        {
        case .failure(let error):
            async
            let checker:Void = channel.close()

            let exit:ExitStatus = await self.sequence(error: error, host: host)

            await checker

            return exit
        
        case .success(let response):
            helloResponse = response
        }

        let pool:Mongo.ConnectionPool = .init(generation: generation,
            signaling: heartbeat.heart,
            bootstrap: self.bootstrap,
            host: host)

        switch await self.check(host: host,
                initialHelloResponse: helloResponse,
                every: heartbeat,
                over: channel,
                pool: pool)
        {
        case .failure(let error):
            async
            let checker:Void = channel.close()
            async
            let pool:Void = pool.drain()

            let exit:ExitStatus = await self.sequence(error: error, host: host)

            await checker
            await pool

            return exit
        
        case .success:
            //  a variety of errors can happen while checking a server.
            //  but if the checker returns without an error, that means
            //  that monitoring was explicitly halted. so we never try
            //  to reconnect on this path.
            async
            let pool:Void = pool.drain()

            await channel.close()
            await pool

            return .stop
        }
    }
    private
    func check(host:Mongo.Host, initialHelloResponse initial:Mongo.HelloResponse,
        every heartbeat:Heartbeat,
        over channel:MongoChannel,
        pool:Mongo.ConnectionPool) async -> Result<Void, any Error>
    {
        guard await self.sequence(update: initial.update,
                sessions: initial.sessions,
                pool: pool,
                host: host)
        else
        {
            return .success(())
        }
        do
        {
            for try await _:Void in heartbeat
            {
                let subsequent:Mongo.HelloResponse = try await channel.run(
                    hello: .init(user: nil))
                if  subsequent.token != initial.token
                {
                    throw Mongo.ConnectionTokenError.init(recorded: initial.token,
                        invalid: subsequent.token)
                }
                guard await self.sequence(update: subsequent.update,
                        sessions: subsequent.sessions,
                        pool: pool,
                        host: host)
                else
                {
                    break
                }
            }
            return .success(())
        }
        catch let error
        {
            return .failure(error)
        }
    }
}
