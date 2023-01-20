import Atomics
import Durations
import DequeModule

extension Mongo
{
    public final
    actor SessionPool
    {
        @usableFromInline nonisolated
        let cluster:Cluster

        private nonisolated
        let releasing:UnsafeAtomic<Int>

        private
        var retained:Set<SessionIdentifier>
        private
        var released:Deque<SessionMetadata>

        /// All requests currently awaiting sessions.
        /// Entering this should be very rare, because session requests can
        /// only block while the pool is re-indexing released sessions.
        private
        var requests:Deque<CheckedContinuation<SessionMetadata, Never>>

        private
        var state:State

        init(cluster:Cluster) 
        {
            self.cluster = cluster
            self.releasing = .create(0)
            self.released = []
            self.retained = []
            self.requests = []
            self.state = .filling
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
            guard case .draining(nil) = self.state
            else
            {
                fatalError("unreachable (deinitialized session pool that has not been drained!)")
            }
        }
    }
}
extension Mongo.SessionPool
{
    /// The total number of sessions stored in the session pool.
    public
    var count:Int
    {
        self.retained.count + self.released.count
    }
}
extension Mongo.SessionPool
{
    @available(*, deprecated)
    public nonisolated
    func withSession<Success>(
        _ body:(Mongo.Session) async throws -> Success) async throws -> Success
    {
        try await body(try await .init(from: self))
    }
    nonisolated
    func create() async throws -> Mongo.SessionMetadata
    {
        let deadline:Mongo.ConnectionDeadline = self.cluster.timeout.deadline(clamping: nil)
        let sessions:Mongo.LogicalSessions = try await self.cluster.sessions(by: deadline)
        return await self.create(ttl: sessions.ttl)
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
    func yield(_ session:Mongo.SessionMetadata) -> Bool
    {
        if case ()? = self.requests.popFirst()?.resume(returning: session)
        {
            return true
        }
        else
        {
            return false
        }
    }
    func drain() async -> [Mongo.SessionIdentifier]
    {
        if case .draining(_?) = self.state
        {
            fatalError("unreachable (draining session pool that is already being drained!)")
        }

        defer
        {
            self.released = []
        }
        if  self.retained.isEmpty
        {
            self.state = .draining(nil)
        }
        else
        {
            await withCheckedContinuation
            {
                self.state = .draining($0)
            }
        }
        return self.released.map(\.id)
    }
}
extension Mongo.SessionPool
{
    nonisolated
    func destroy(_ session:Mongo.SessionMetadata, reuse:Bool)
    {
        if  reuse
        {
            self.releasing.wrappingIncrement(ordering: .relaxed)
        }
        let _:Task<Void, Never> = .init
        {
            await self.destroy(session, reindex: reuse)
        }
    }
    private
    func destroy(_ session:Mongo.SessionMetadata, reindex:Bool)
    {
        if  reindex
        {
            self.releasing.wrappingDecrement(ordering: .relaxed)
        }
        switch self.state
        {
        case .filling:
            guard reindex
            else
            {
                // dirty sessions do not use `endSessions`, per
                // https://github.com/mongodb/specifications/blob/master/source/sessions/driver-sessions.rst#why-don-t-drivers-run-the-endsessions-command-to-cleanup-dirty-server-sessions
                self.retained.remove(session.id)
                return
            }
            guard self.yield(session)
            else
            {
                self.retained.remove(session.id)
                self.released.append(session)
                return
            }
        
        case .draining(let continuation):
            self.retained.remove(session.id)
            self.released.append(session)

            if self.retained.isEmpty
            {
                continuation?.resume()
                self.state = .draining(nil)
            }
        }
    }
    private
    func create(ttl:Minutes) async -> Mongo.SessionMetadata
    {
        guard case .filling = self.state
        else
        {
            fatalError("unreachable (checking out a session while pool is being drained!)")
        }

        let now:ContinuousClock.Instant = .now

        //  prune expired sessions from the front of the deque
        while   let session:Mongo.SessionMetadata = self.released.first,
                    session.expiration(ttl: ttl) <= now
        {
            self.released.removeFirst()
        }
        //  find a non-expired session at the end of the deque
        while let session:Mongo.SessionMetadata = self.released.popLast()
        {
            guard now < session.expiration(ttl: ttl)
            else
            {
                continue
            }
            if case nil = self.retained.update(with: session.id)
            {
                return session
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
                return .init(transaction: .init(), touched: now, id: id)
            }
        }
    }
}
extension Mongo.SessionPool
{
    @inlinable public nonisolated
    func withDirectConnections<Success>(to preference:Mongo.ReadPreference,
        by deadline:Mongo.ConnectionDeadline? = nil,
        _ body:(Mongo.ConnectionPool) async throws -> Success) async throws -> Success
    {
        let connect:Mongo.ConnectionDeadline = deadline ??
            self.cluster.timeout.deadline(from: .now)
        let pool:Mongo.ConnectionPool = try await self.cluster.pool(
            preference: preference,
            by: connect)
        return try await body(pool)
    }
}
extension Mongo.SessionPool
{
    /// Runs a session command against the specified database,
    /// sending the command to an appropriate cluster member for its type.
    @inlinable public nonisolated
    func run<Command>(command:Command, against database:Command.Database,
        on preference:Mongo.ReadPreference = .primary,
        by deadline:ContinuousClock.Instant? = nil) async throws -> Command.Response
        where Command:MongoImplicitSessionCommand
    {
        let started:ContinuousClock.Instant = .now
        let session:Mongo.Session = try await .init(from: self)
        return try await session.run(command: command, against: database,
            on: preference,
            by: deadline,
            started: started)
    }
}
