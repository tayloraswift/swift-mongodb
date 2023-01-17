import Atomics
import Durations

extension Mongo
{
    public final
    actor Cluster
    {
        /// The combined connection and operation timeout for driver operations.
        public nonisolated
        let timeout:ConnectionTimeout

        private
        var selectionRequests:[UInt: SelectionRequest]
        private
        var sessionsRequests:[UInt: SessionsRequest]
        private
        var counter:UInt

        private nonisolated
        let atomic:
        (
            sessions:UnsafeAtomic<LogicalSessions>,
            time:UnsafeAtomic<AtomicTime?>
        )

        private
        var snapshot:Servers

        init(timeout:ConnectionTimeout)
        {
            self.timeout = timeout
            
            self.atomic.sessions = .create(.init(ttl: 0))
            self.atomic.time = .create(nil)
            self.snapshot = .none

            self.selectionRequests = [:]
            self.sessionsRequests = [:]
            self.counter = 0
        }

        deinit
        {
            self.atomic.sessions.destroy()
            self.atomic.time.destroy()

            guard self.selectionRequests.isEmpty
            else
            {
                fatalError("unreachable (deinitialized while selection requests are awaiting!)")
            }
            guard self.sessionsRequests.isEmpty
            else
            {
                fatalError("unreachable (deinitialized while session requests are awaiting!)")
            }
        }
    }
}

extension Mongo.Cluster
{
    public nonisolated
    var sessions:Mongo.LogicalSessions?
    {
        let sessions:Mongo.LogicalSessions = self.atomic.sessions.load(ordering: .relaxed)
        return sessions.ttl == 0 ? nil : sessions
    }
    /// The current largest-seen cluster time, if any.
    public nonisolated
    var time:Mongo.ClusterTime
    {
        .init(self.atomic.time.load(ordering: .relaxed)?.value)
    }
}
extension Mongo.Cluster
{
    public nonisolated
    func push(time:Mongo.ClusterTime.Sample?)
    {
        guard let time:Mongo.ClusterTime.Sample
        else
        {
            return
        }
        let _:Task<Void, Never> = .init
        {
            await self.push(time: time)
        }
    }
    func push(time:Mongo.ClusterTime.Sample)
    {
        self.atomic.time.store(.init(self.time.combined(with: time)), ordering: .relaxed)
    }
    func push(snapshot:Mongo.Servers, sessions:Mongo.LogicalSessions? = nil)
    {
        self.snapshot = snapshot

        for (id, request):(UInt, SelectionRequest) in self.selectionRequests
        {
            if  let pool:Mongo.ConnectionPool = self.snapshot[request.preference]
            {
                self.selectionRequests[id].fulfill(with: pool)
            }
        }

        guard let sessions:Mongo.LogicalSessions
        else
        {
            return
        }

        switch self.sessions.map({ sessions.ttl < $0.ttl })
        {
        case nil, true?:
            self.atomic.sessions.store(sessions, ordering: .relaxed)
        case false?:
            break
        }

        for id:UInt in self.sessionsRequests.keys
        {
            self.sessionsRequests[id].fulfill(with: sessions)
        }
    }
}
extension Mongo.Cluster
{
    private
    func request() -> UInt
    {
        self.counter += 1
        return self.counter
    }
}
extension Mongo.Cluster
{
    /// Returns deployment-wide logical session parameters, without suspending,
    /// if the cluster is known to support logical sessions. Suspends for at most
    /// the specified amount of time otherwise, returning as soon as this
    /// information becomes available.
    ///
    /// This method often suspends if it is called immediately after initializing
    /// a session pool, because the pool did not have time to connect to any
    /// servers yet.
    public nonisolated
    func sessions(by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.LogicalSessions
    {
        if  let sessions:Mongo.LogicalSessions = self.sessions
        {
            return sessions
        }
        else
        {
            return try await self.sessionsAvailable(by: deadline)
        }
    }
    private
    func sessionsAvailable(
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.LogicalSessions
    {
        let id:UInt = self.request()

        async
        let _:Void = self.sessionsUnavailable(for: id, once: deadline)

        return try await withCheckedThrowingContinuation
        {
            self.sessionsRequests.updateValue(.init(promise: $0),
                forKey: id)
        }
    }
    private
    func sessionsUnavailable(for id:UInt, once deadline:Mongo.ConnectionDeadline) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: deadline.instant, clock: .continuous)
        self.sessionsRequests[id].fail(diagnosing: self.snapshot)
    }
}
extension Mongo.Cluster
{
    // @inlinable public nonisolated
    // func withConnection<Success>(
    //     to preference:Mongo.ReadPreference,
    //     by deadline:ContinuousClock.Instant,
    //     run body:(Mongo.Connection) async throws -> Success) async throws -> Success
    // {
    //     try await self.pool(preference: preference, by: deadline).withConnection(by: deadline,
    //         run: body)
    // }

    @usableFromInline
    func pool(preference:Mongo.ReadPreference,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.ConnectionPool
    {
        if  let pool:Mongo.ConnectionPool = self.snapshot[preference]
        {
            return pool
        }
        else
        {
            return try await self.poolAvailable(preference: preference, by: deadline)
        }
    }
    private
    func poolAvailable(preference:Mongo.ReadPreference,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.ConnectionPool
    {
        let id:UInt = self.request()

        async
        let _:Void = self.poolUnavailable(for: id, once: deadline)

        return try await withCheckedThrowingContinuation
        {
            self.selectionRequests.updateValue(.init(preference: preference, promise: $0),
                forKey: id)
        }
    }
    private
    func poolUnavailable(for id:UInt, once deadline:Mongo.ConnectionDeadline) async throws
    {
        //  will throw ``CancellationError`` if request succeeds
        try await Task.sleep(until: deadline.instant, clock: .continuous)
        self.selectionRequests[id].fail(diagnosing: self.snapshot)
    }
}
extension Mongo.Cluster
{
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
    ///     [`true`]() if `sessions` was empty or the command was sent
    ///     and successfully executed; [`false`]() if at least one session was
    ///     provided, but there were no suitable servers to send the command
    ///     to, or if the command was sent but it failed on the server’s side.
    ///
    /// This method will not submit any work to the actor if `sessions` is empty.
    @discardableResult
    nonisolated
    func end(sessions:__owned [Mongo.SessionIdentifier]) async -> Bool
    {
        guard let command:Mongo.EndSessions = .init(sessions)
        else
        {
            return true
        }
        do
        {
            let deadline:Mongo.ConnectionDeadline = self.timeout.deadline(from: .now)

            let connections:Mongo.ConnectionPool = try await self.pool(
                preference: .primaryPreferred,
                by: deadline)
            let connection:Mongo.Connection = try await connections.create(
                by: deadline)
            defer
            {
                connections.destroy(connection)
            }
            
            let reply:Mongo.Reply = try await connection.channel.run(command: command,
                against: .admin,
                by: deadline.instant)
            
            switch reply.result
            {
            case .success:
                return true
            case .failure:
                return false
            }
        }
        catch
        {
            return false
        }
    }
}
