import Atomics
import Durations

extension Mongo
{
    /// A type that models the state of a MongoDB deployment.
    ///
    /// Instances of this type are responsible for storing the following information:
    ///
    /// -   Whether or not the deployment supports logical sessions, and if so,
    ///     what the logical session TTL is.
    /// -   What the current largest-seen cluster time is, and proof that that
    ///     cluster time came from a `mongod`/`mongos` server.
    /// -   A snapshot of the current cluster topology, which contains references
    ///     to the current ``ConnectionPool`` associated with each reachable server.
    ///
    /// Instances of this type are responsible for making this information available
    /// to other tasks in a timely fashion. It is not responsible for computing or
    /// sequencing topology updates.
    ///
    /// Having a separate actor loop for publishing the deployment model means
    /// types like ``Session`` and ``SessionPool`` don’t need to interact with
    /// the service monitor, and service monitoring computations don’t block requests
    /// for information about deployment state.
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
    var time:Mongo.ClusterTime?
    {
        self.atomic.time.load(ordering: .relaxed)?.value
    }
}
extension Mongo.Cluster
{
    /// Synchronously yield an observed cluster time to this deployment model.
    /// The time sample will be integrated into the deployment state
    /// asynchronously.
    ///
    /// It is expected that many concurrent tasks will yield non-monotinic
    /// cluster time observations; the deployment model will sequence the
    /// observations and publish a monotonically increasing global cluster time.
    ///
    /// This works differently from topology snapshot updates, which are pushed
    /// by a single actor loop (the `Monitor`) in a blocking fashion.
    @usableFromInline nonisolated
    func yield(clusterTime:Mongo.ClusterTime?)
    {
        guard let clusterTime:Mongo.ClusterTime
        else
        {
            return
        }
        let _:Task<Void, Never> = .init
        {
            await self.combine(clusterTime)
        }
    }
    /// Updates the stored cluster time if the given time is greater. This is
    /// actor-isolated even though it only uses non-isolated operations, to prevent
    /// races between the atomic load and the atomic store.
    private
    func combine(_ clusterTime:Mongo.ClusterTime)
    {
        let current:Mongo.AtomicTime? = self.atomic.time.load(ordering: .relaxed)
        self.atomic.time.store(clusterTime.combined(with: current), ordering: .relaxed)
    }
}
extension Mongo.Cluster
{
    /// Pushes a topology snapshot to the deployment model, along with information
    /// about the deployment’s logical sessions support.
    ///
    /// Unlike the cluster time, topology updates are computationally intensive, and
    /// so they are not calculated on the deployment model’s actor loop, to avoid
    /// blocking tasks that need to read the deployment state.
    ///
    /// This method should only be called from a single task or actor context, and
    /// the caller should always wait for the call to complete in order to ensure
    /// sequential consistency.
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
            let connection:Mongo.Connection = try await .init(from: connections,
                by: deadline)
            
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
