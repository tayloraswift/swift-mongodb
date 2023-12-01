import Atomics
import DequeModule
import Durations

extension Mongo
{
    /// An interface for creating driver sessions.
    ///
    /// Session pools have precise lifetime semantics, so you cannot create them
    /// directly. Instead, call a method like `withSessionPool` on
    /// ``DriverBootstrap``, which yields a session pool, and performs necessary
    /// cleanup on shutdown.
    public final
    actor SessionPool
    {
        /// A reference to a deployment model. The session pool uses it directly,
        /// and also copies (strong-references) it to give to individual
        /// ``Session`` objects.
        @usableFromInline nonisolated
        let deployment:Deployment

        /// The number of sessions currently being re-indexed by this pool.
        /// Session deinitializers increment this counter, and the pool 
        /// decrements it once the session has been re-indexed and made available
        /// for reuse.
        private nonisolated
        let releasing:UnsafeAtomic<Int>

        private
        var retained:Set<SessionIdentifier>
        private
        var released:Deque<Allocation>

        /// All requests currently awaiting sessions.
        /// Entering this should be very rare, because session requests can
        /// only block while the pool is re-indexing released sessions.
        private
        var requests:Deque<CheckedContinuation<Allocation, Never>>

        private
        var observers:Observers
        private
        var phase:Phase

        init(deployment:Deployment) 
        {
            self.deployment = deployment
            self.releasing = .create(0)
            self.released = []
            self.retained = []
            self.requests = []
            self.observers = .none
            self.phase = .filling
        }

        deinit
        {
            self.releasing.destroy()

            guard self.requests.isEmpty
            else
            {
                fatalError("unreachable (deinitialized session pool while continuations are awaiting!)")
            }
            guard self.retained.isEmpty, self.released.isEmpty
            else
            {
                fatalError("unreachable (deinitialized session pool while pool contains sessions!)")
            }
            guard case .draining = self.phase
            else
            {
                fatalError("unreachable (deinitialized session pool that has not been drained!)")
            }
        }
    }
}
extension Mongo.SessionPool
{
    public nonisolated
    var logger:Mongo.Logger?
    {
        self.deployment.logger
    }
    /// The total number of sessions stored in the session pool.
    public
    var count:Int
    {
        self.retained.count + self.released.count
    }
}
extension Mongo.SessionPool
{
    /// Awaits and returns a connection pool to a server matching the specified
    /// read preference.
    ///
    /// The returned connection pool can only provide connections to the server
    /// while it is being continuously monitored. If connectivity is lost, the
    /// connection pool will begin draining, and the service monitoring system
    /// will eventually replace it with a new pool if it is able to reconnect.
    /// Therefore, for maximum fault-tolerance, you should avoid holding connection
    /// pools for long periods of time, and instead acquire them as needed before
    /// executing database operations.
    public nonisolated
    func connect(to preference:Mongo.ReadPreference,
        by deadline:ContinuousClock.Instant? = nil) async throws -> Mongo.ConnectionPool
    {
        try await self.deployment.pool(selecting: preference,
            by: deadline ?? self.deployment.timeout.deadline())
    }
}
extension Mongo.SessionPool
{
    /// Runs a command against the specified database using an implicitly-assigned
    /// session. The connection will be obtained first, and then a session will
    /// be assigned to it, which is different from creating a `Session` manually
    /// and calling `Session.run(command:against:on:by:)`.
    ///
    /// When sending many commands with implicit sessions at the same time, ordering
    /// the blocking steps like this prevents the session pool from generating an
    /// excessive number of parallel sessions if the commands themselves can only
    /// executed a few at a time.
    @inlinable public nonisolated
    func run<Command>(command:Command, against database:Command.Database,
        on preference:Mongo.ReadPreference = .primary,
        by deadline:ContinuousClock.Instant? = nil) async throws -> Command.Response
        where Command:MongoImplicitSessionCommand
    {
        let deadlines:Mongo.Deadlines = self.deployment.timeout.deadlines(clamping: deadline)

        let connections:Mongo.ConnectionPool = try await self.deployment.pool(
            selecting: preference,
            by: deadlines.connection)
        //  this creates the connection before creating the session, because
        //  connections are limited but sessions are unlimited. so ordering it
        //  like this 
        let connection:Mongo.Connection = try await .init(from: connections,
            by: deadlines.connection)
        let session:Mongo.Session = try await .init(from: self)

        return try await session.run(command: command, against: database,
            over: connection,
            on: preference,
            by: deadlines.operation)
    }
}
extension Mongo.SessionPool
{
    /// Transitions the pool in a draining state, and waits for all created sessions
    /// to be destroyed.
    ///
    /// -   Returns:
    ///     An array of the identifiers of all the sessions in the pool. This array
    ///     does not include sessions that were linted because the driver believed
    ///     them to already be expired, or sessions that were discarded on destruction.
    func drain() async -> [Mongo.SessionIdentifier]
    {
        self.phase = .draining

        defer
        {
            self.released = []
        }
        if  self.retained.isEmpty
        {
            self.observers.resume()
        }
        else
        {
            await withCheckedContinuation
            {
                self.observers.append($0)
            }
        }
        return self.released.map(\.id)
    }
}
extension Mongo.SessionPool
{
    /// Unblocks an awaiting request with the given session, if one exists.
    ///
    /// -   Returns:
    ///     [`true`]() if there was a request that was unblocked by this call,
    ///     [`false`]() otherwise.
    private
    func yield(_ allocation:Allocation) -> Bool
    {
        if case ()? = self.requests.popFirst()?.resume(returning: allocation)
        {
            true
        }
        else
        {
            false
        }
    }
}
extension Mongo.SessionPool
{
    /// Create (unsafe) session metadata. A successful call to this method must
    /// be paired with a later call to ``destroy(_:reuse:)``.
    ///
    /// Expected usage is to immediately wrap the session metadata in a reference
    /// or move-only type, such as ``Session``, which destroys the session metadata
    /// on its `deinit`.
    func create(capabilities:Mongo.DeploymentCapabilities) async -> Allocation
    {
        guard case .filling = self.phase
        else
        {
            fatalError("unreachable (checking out a session while pool is being drained!)")
        }

        let now:ContinuousClock.Instant = .now

        //  prune expired sessions from the front of the deque
        while   let allocation:Allocation = self.released.first,
                    allocation.expiration(ttl: capabilities.sessions.ttl) <= now
        {
            self.released.removeFirst()
        }
        //  find a non-expired session at the end of the deque
        while let allocation:Allocation = self.released.popLast()
        {
            guard now < allocation.expiration(ttl: capabilities.sessions.ttl)
            else
            {
                continue
            }
            if case nil = self.retained.update(with: allocation.id)
            {
                return allocation
            }
            else
            {
                fatalError("unreachable (retained a session more than once!)")
            }
        }
        //  check that there are not enough currently-releasing sessions
        //  to satisfy all outstanding requests, including this one
        guard self.releasing.load(ordering: .relaxed) <= self.requests.count
        else
        {
            return await withCheckedContinuation
            {
                self.requests.append($0)
            }
        }
        //  generate a new one if there are none available
        while true
        {
            // very unlikely, but do not generate a session id that we have
            // already generated. this is not foolproof (because we could
            // have persistent sessions from a previous run), but allows us
            // to maintain local dictionary invariants.
            let id:Mongo.SessionIdentifier = .random()
            if case nil = self.retained.update(with: id)
            {
                return .init(
                    transaction: .init(capabilities.transactions.map { _ in .autocommitting }),
                    touched: now,
                    id: id)
            }
        }
    }
    /// Destroy (unsafe) session metadata. The session will re-indexed by the
    /// pool if `reuse` is true, otherwise it will be discarded.
    nonisolated
    func destroy(_ allocation:Allocation, reuse:Bool)
    {
        if  reuse
        {
            self.releasing.wrappingIncrement(ordering: .relaxed)
        }
        let _:Task<Void, Never> = .init
        {
            await self.destroy(allocation, reindex: reuse)
        }
    }
    private
    func destroy(_ allocation:Allocation, reindex:Bool)
    {
        if  reindex
        {
            self.releasing.wrappingDecrement(ordering: .relaxed)
        }
        switch self.phase
        {
        case .filling:
            guard reindex
            else
            {
                // dirty sessions do not use `endSessions`, per
                // https://github.com/mongodb/specifications/blob/master/source/sessions/driver-sessions.rst#why-don-t-drivers-run-the-endsessions-command-to-cleanup-dirty-server-sessions
                self.retained.remove(allocation.id)
                return
            }
            guard self.yield(allocation)
            else
            {
                self.retained.remove(allocation.id)
                self.released.append(allocation)
                return
            }
        
        case .draining:
            self.retained.remove(allocation.id)
            self.released.append(allocation)

            if  self.retained.isEmpty
            {
                self.observers.resume()
            }
        }
    }
}
