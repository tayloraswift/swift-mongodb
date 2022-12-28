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
        nonisolated
        let bootstrap:DriverBootstrap

        private
        var topology:MongoTopology
        private
        var awaiting:SessionMediumRequests
        private
        var tasks:Tasks
        private
        var ttl:Minutes?

        /// The current largest-seen cluster time.
        private nonisolated
        let _clusterTime:UnsafeAtomic<Unmanaged<ClusterTime>?>
        /// A clock used to mediate request timeouts. Has nothing to do with cluster times.
        private nonisolated
        let clock:ContinuousClock

        init(bootstrap:DriverBootstrap) 
        {
            self.bootstrap = bootstrap

            self.topology = .terminated
            self.awaiting = .init()
            self.tasks = .init()
            self.ttl = nil

            self._clusterTime = .create(nil)
            self.clock = .init()
        }

        deinit
        {
            let _:ClusterTime? = self._clusterTime.destroy()?.takeRetainedValue()

            guard self.awaiting.isEmpty
            else
            {
                fatalError("unreachable (deinitialized while continuations are awaiting)")
            }
        }
    }
}
extension Mongo.Monitor
{
    // TODO: we don’t need to traffic the allocated object outside of this setter
    nonisolated public
    var clusterTime:Mongo.ClusterTime?
    {
        get
        {
            self._clusterTime.load(ordering: .relaxed)?.takeUnretainedValue()
        }
        set(value)
        {
            guard let value:Mongo.ClusterTime
            else
            {
                return
            }

            let owned:Unmanaged<Mongo.ClusterTime> = .passRetained(value)
            var shared:Unmanaged<Mongo.ClusterTime>? = self._clusterTime.load(
                ordering: .relaxed)
            
            while true
            {
                if  let old:Mongo.ClusterTime = shared?.takeUnretainedValue(),
                        old.max.timestamp >= value.max.timestamp
                {
                    owned.release()
                    return
                }

                switch self._clusterTime.weakCompareExchange(expected: shared, desired: owned,
                    successOrdering: .acquiringAndReleasing,
                    failureOrdering: .acquiring)
                {
                case (exchanged: false, let current):
                    shared = current
                
                case (exchanged: true, let owned?):
                    owned.release()
                    return
                
                case (exchanged: true, nil):
                    return
                }
            }
        }
    }
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
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
    {
        self.topology.clear(host: host, status: status)
    }
    private
    func update(host:MongoTopology.Host, channel:MongoChannel,
        metadata:Mongo.ServerMetadata) -> Bool
    {
        let admitted:Bool = self.topology.update(host: host, channel: channel,
            metadata: metadata.type)
        { 
            let _:Task<Void, Never>? = self.monitor($0) 
        }
        if  admitted
        {
            // update session timeout
            let ttl:Minutes = min(self.ttl ?? metadata.ttl, metadata.ttl)
            self.ttl = ttl
            // succeed any tasks awaiting connections
            if      let channel:MongoChannel = self.topology.master
            {
                self.awaiting.fulfill(with: .init(channel: channel, ttl: ttl))
                {
                    _ in true
                }
            }
            else if let channel:MongoChannel = self.topology.any
            {
                self.awaiting.fulfill(with: .init(channel: channel, ttl: ttl))
                {
                    switch $0
                    {
                    case .any:      return true
                    case .master:   return false
                    }
                }
            }
        }
        return admitted
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

            if self.clear(host: host, status: status)
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
        let heartbeat:Heartbeat = .init(interval: .milliseconds(1000))
        let channel:MongoChannel = try await self.bootstrap.channel(to: host,
            attaching: heartbeat.heart)
        
        defer
        {
            // will be a no-op if the channel closed spontaneously,
            // terminating the stream of heartbeats
            channel.close()
        }

        //  initial login, performs auth (if using auth).
        let initial:Mongo.Hello.Response = try await channel.establish(
            credentials: self.bootstrap.credentials,
            appname: self.bootstrap.appname)
        
        guard self.update(host: host, channel: channel, metadata: initial.metadata)
        else
        {
            return
        }

        for try await _:Void in heartbeat
        {
            let updated:Mongo.Hello.Response = try await channel.run(
                hello: .init(user: nil))
            if  updated.token != initial.token
            {
                throw MongoChannel.TokenError.init(recorded: initial.token,
                    invalid: updated.token)
            }
            guard self.update(host: host, channel: channel, metadata: updated.metadata)
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
    func medium(_ selector:Mongo.SessionMediumSelector,
        timeout:Duration) async throws -> Mongo.SessionMedium
    {
        if  let channel:MongoChannel = self.topology[selector],
            let ttl:Minutes = self.ttl
        {
            return .init(channel: channel, ttl: ttl)
        }
        else
        {
            let started:ContinuousClock.Instant = self.clock.now
            let id:UInt = self.awaiting.open()

            #if compiler(>=5.8)
            async
            let _:Void = self.fail(request: id, once: started.advanced(by: timeout))
            #else
            async
            let __:Void = self.fail(request: id, once: started.advanced(by: timeout))
            #endif

            return try await withCheckedThrowingContinuation
            {
                self.awaiting.submit(id, request: .init(promise: $0, of: selector))
            }
        }
    }
    private
    func fail(request:UInt, once instant:ContinuousClock.Instant) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: instant, clock: self.clock)
        self.awaiting.fail(request, errored: self.topology.errors())
    }

    /// Sends an ``EndSessions`` command ending the given list of sessions
    /// to an appropriate server for this deployment’s topology, and awaits
    /// its response. 
    ///
    /// -   Parameters:
    ///     -   sessions:
    ///         A list of sessions to include with the ``EndSessions``
    ///         command. This method will return immediately without
    ///         sending any command if `sessions` is empty.
    ///
    /// -   Returns:
    ///     A ``Void`` tuple if `sessions` was empty or the command was sent
    ///     and successfully executed; [`nil`]() if at least one session was
    ///     provided, but there were no suitable servers to send the command
    ///     to, or if the command was sent but it failed on the server’s side.
    ///
    /// This method will not acquire the actor lock if `sessions` is empty.
    nonisolated
    func end(sessions:__owned [Mongo.SessionIdentifier]) async -> Void?
    {
        if let command:Mongo.EndSessions = .init(sessions)
        {
            return try? await self.run(endSessions: command)
        }
        else
        {
            return ()
        }
    }
    private
    func run(endSessions command:__owned Mongo.EndSessions) async throws -> Void?
    {
        switch self.topology
        {
        case .terminated, .unknown(_):
            return nil
        
        case .single(let topology):
            return try await topology.master?.run(endSessions: command)
        
        case .sharded(let topology):
            //  ``EndSessions`` can be sent to any `mongos`.
            return try await topology.any?.run(endSessions: command)
        
        case .replicated(let topology):
            //  ``EndSessions`` should be sent to the primary if available,
            //  or any available secondary otherwise.
            //  the spec says we should send the command *once*, and ignore
            //  all errors, so we will not retry the command on a secondary
            //  if it failed on the primary.
            return try await (topology.master ?? topology.any)?.run(endSessions: command)
        }
    }
}
