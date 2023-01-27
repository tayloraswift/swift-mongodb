extension Mongo
{
    public
    struct Transaction
    {
        @usableFromInline
        let session:Session
        @usableFromInline
        let pinned:ConnectionPool

        init(session:Session, pinned:ConnectionPool)
        {
            self.session = session
            self.pinned = pinned
        }
    }
}
extension Mongo.Transaction
{
    func abort(with writeConcern:Mongo.WriteConcern?) async throws
    {
        try await self.run(command: Mongo.AbortTransaction.init(
                writeConcern: writeConcern),
            against: .admin)
    }
    func commit(with writeConcern:Mongo.WriteConcern?) async throws
    {
        try await self.run(command: Mongo.CommitTransaction.init(
                writeConcern: writeConcern),
            against: .admin)
    }
}
extension Mongo.Transaction
{
    @inlinable public
    var preconditionTime:Mongo.Instant?
    {
        self.session.preconditionTime
    }
    @inlinable public
    var state:Mongo.TransactionState
    {
        self.session.transaction
    }
}
extension Mongo.Transaction
{
    @available(*, unavailable, message: "`RefreshSessions` cannot be run during a transaction.")
    public
    func refresh() async throws
    {
    }
}
extension Mongo.Transaction
{
    @inlinable public
    func run<Command>(command:Command, against database:Command.Database,
        by deadline:ContinuousClock.Instant? = nil) async throws -> Command.Response
        where Command:MongoTransactableCommand
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
        where Query:MongoTransactableCommand & MongoQuery
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
