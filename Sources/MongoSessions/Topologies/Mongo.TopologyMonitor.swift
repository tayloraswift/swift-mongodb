import Atomics
import BSON
import Heartbeats
import MongoWire
import NIOCore

extension Mongo
{
    /// A deployment topology monitor.
    public final
    actor TopologyMonitor
    {
        let driver:Driver

        private
        var topology:Topology
        private
        var awaiting:SessionMediumRequests
        private
        var tasks:Tasks
        private
        var ttl:Mongo.Minutes?

        nonisolated
        let time:UnsafeAtomic<UInt64>

        init(driver:Driver) 
        {
            self.driver = driver

            self.topology = .terminated
            self.awaiting = .init()
            self.tasks = .init()
            self.ttl = nil

            self.time = .create(0)
        }

        deinit
        {
            self.time.destroy()

            guard self.awaiting.isEmpty
            else
            {
                fatalError("unreachable (deinitialized while continuations are awaiting)")
            }

            print("deinitialized topology monitor")
        }
    }
}
extension Mongo.TopologyMonitor
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
    func clear(host:Mongo.Host, status:(any Error)?) -> Void?
    {
        self.topology.clear(host: host, status: status)
    }
    private
    func update(host:Mongo.Host, connection:Mongo.Connection,
        metadata:Mongo.ServerMetadata) -> Void?
    {
        self.topology.update(host: host, connection: connection, metadata: metadata.type)
        {
            let _:Task<Void, Never>? = self.monitor($0)
        }
            .map
        {
            // update session timeout
            let ttl:Mongo.Minutes = min(self.ttl ?? metadata.ttl, metadata.ttl)
            self.ttl = ttl
            // succeed any tasks awaiting connections
            if      let connection:Mongo.Connection = self.topology.master
            {
                self.awaiting.fulfill(with: .init(connection: connection, ttl: ttl))
                {
                    _ in true
                }
            }
            else if let connection:Mongo.Connection = self.topology.any
            {
                self.awaiting.fulfill(with: .init(connection: connection, ttl: ttl))
                {
                    switch $0
                    {
                    case .any:      return true
                    case .master:   return false
                    }
                }
            }
        }
    }
}
extension Mongo.TopologyMonitor
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

            if case ()? = self.clear(host: host, status: status)
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
    func connect(to host:Mongo.Host) async throws
    {
        let heartbeat:Heartbeat = .init(interval: .milliseconds(1000))
        let connection:Mongo.Connection = try await self.driver.connect(to: host,
            heart: heartbeat.heart)
        
        defer
        {
            // will be a no-op if the connection closed spontaneously,
            // terminating the stream of heartbeats
            connection.close()
        }

        //  initial login, performs auth (if using auth).
        let initial:Mongo.Hello.Response = try await connection.establish(
            credentials: self.driver.credentials)
        
        self.update(host: host, connection: connection, metadata: initial.metadata)

        for try await _:Void in heartbeat
        {
            let updated:Mongo.Hello.Response = try await connection.run(
                command: .init(user: nil))
            if  updated.token == initial.token
            {
                self.update(host: host, connection: connection, metadata: updated.metadata)
            }
            else
            {
                throw Mongo.ConnectionTokenError.init(recorded: initial.token,
                    invalid: updated.token)
            }
        }
    }
}
extension Mongo.TopologyMonitor
{
    /// Attempts to obtain a connection to a cluster member matching the given
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
        if  let connection:Mongo.Connection = self.topology[selector],
            let ttl:Mongo.Minutes = self.ttl
        {
            return .init(connection: connection, ttl: ttl)
        }
        else
        {
            let started:ContinuousClock.Instant = self.driver.clock.now
            let id:UInt = self.awaiting.open()

            async
            let _:Void = self.fail(request: id, once: started.advanced(by: timeout))

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
        try await Task.sleep(until: instant, clock: self.driver.clock)
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
        if let sessions:Mongo.EndSessions = .init(sessions)
        {
            return try? await self.end(sessions: sessions)
        }
        else
        {
            return ()
        }
    }
    private
    func end(sessions command:__owned Mongo.EndSessions) async throws -> Void?
    {
        switch self.topology
        {
        case .terminated, .unknown(_):
            return nil
        
        case .single(let topology):
            return try await topology.master?.run(command: command)
        
        case .sharded(let topology):
            //  ``EndSessions`` can be sent to any `mongos`.
            return try await topology.any?.run(command: command)
        
        case .replicated(let topology):
            //  ``EndSessions`` should be sent to the primary if available,
            //  or any available secondary otherwise.
            //  the spec says we should send the command *once*, and ignore
            //  all errors, so we will not retry the command on a secondary
            //  if it failed on the primary.
            return try await (topology.master ?? topology.any)?.run(command: command)
        }
    }
}
