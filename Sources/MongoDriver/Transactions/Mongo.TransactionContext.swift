extension Mongo
{
    public
    struct TransactionContext
    {
        @usableFromInline
        let session:Session
        @usableFromInline
        let pinned:ConnectionPool

        private
        init(session:Session, pinned:ConnectionPool)
        {
            self.session = session
            self.pinned = pinned
        }
    }
}
extension Mongo.TransactionContext
{
    /// Transitions the transaction state of the given session into the starting phase,
    /// and stores the supplied read concern (if any) for use by the next command run
    /// with the owning session. Traps if a transaction is already in progress.
    @usableFromInline
    init(session:Mongo.Session, pinned:Mongo.ConnectionPool,
        with readConcern:Mongo.ReadConcern.Level?)
    {
        if case nil = session.transaction.phase
        {
            session.transaction.number += 1
            session.transaction.phase = .starting(readConcern)
            self.init(session: session, pinned: pinned)
        }
        else
        {
            fatalError(Mongo.Session.transactionNestedErrorMessage)
        }
    }
    @usableFromInline
    func abort(with writeConcern:Mongo.WriteConcern?) async throws
    {
        defer
        {
            self.session.transaction.phase = nil
        }
        if case .started? = self.session.transaction.phase
        {
            try await self.run(
                command: Mongo.AbortTransaction.init(writeConcern: writeConcern),
                against: .admin)
        }
    }
    @usableFromInline
    func commit(with writeConcern:Mongo.WriteConcern?) async throws
    {
        defer
        {
            self.session.transaction.phase = nil
        }
        if case .started? = self.session.transaction.phase
        {
            try await self.run(
                command: Mongo.CommitTransaction.init(writeConcern: writeConcern),
                against: .admin)
        }
    }
}
extension Mongo.TransactionContext
{
    /// Runs a ``RefreshSessions`` command for the current session.
    /// Calling this convenience method is equivalent to constructing a
    /// ``RefreshSessions`` instance with this session’s ``id`` and running it
    /// manually.
    public
    func refresh() async throws
    {
        try await self.run(command: Mongo.RefreshSessions.init(self.session.id),
            against: .admin)
    }
}
extension Mongo.TransactionContext
{
    @inlinable public
    func run<Command>(command:Command, against database:Command.Database,
        by deadline:ContinuousClock.Instant? = nil) async throws -> Command.Response
        where Command:MongoCommand
    {
        let connect:Mongo.ConnectionDeadline = self.session.cluster.timeout.deadline(from: .now,
            clamping: deadline)
        
        let connection:Mongo.Connection = try await .init(from: self.pinned, by: connect)

        return try await self.session.run(command: command, against: database,
            over: connection,
            on: .primary,
            by: deadline ?? connect.instant)
    }
    @inlinable public
    func run<Query, Success>(query:Query, against database:Query.Database,
        on preference:Mongo.ReadPreference = .primary,
        by deadline:ContinuousClock.Instant? = nil,
        with consumer:(Mongo.Batches<Query.Element>) async throws -> Success)
        async throws -> Success
        where Query:MongoQuery
    {
        let connect:Mongo.ConnectionDeadline = self.session.cluster.timeout.deadline(from: .now,
            clamping: deadline)

        return try await self.session.run(query: query, against: database, on: .primary,
            by: deadline ?? connect.instant,
            with: consumer)
        {
            try await .init(from: self.pinned, by: connect)
        }
    }
}
