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
    var preconditionTime:Mongo.Timestamp?
    {
        self.session.preconditionTime
    }
    @inlinable public
    var state:Mongo.TransactionState
    {
        self.session.transaction
    }

    @usableFromInline
    var deployment:Mongo.Deployment
    {
        self.session.deployment
    }
}
extension Mongo.Transaction
{
    @available(*, unavailable, message: "RefreshSessions cannot be run during a transaction.")
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
        let deadlines:Mongo.Deadlines = self.deployment.timeout.deadlines(
            clamping: deadline)

        let connection:Mongo.Connection = try await .init(from: self.pinned,
            by: deadlines.connection)

        return try await self.session.run(command: command, against: database,
            over: connection,
            on: .primary,
            by: deadlines.operation)
    }
    @inlinable public
    func run<Query, Success>(command:Query, against database:Query.Database,
        on preference:Mongo.ReadPreference = .primary,
        by deadline:ContinuousClock.Instant? = nil,
        with consumer:(Mongo.Cursor<Query.Element>) async throws -> Success)
        async throws -> Success
        where Query:MongoTransactableCommand & MongoIterableCommand
    {
        let deadlines:Mongo.Deadlines = self.deployment.timeout.deadlines(
            clamping: deadline)

        let batches:Mongo.Cursor<Query.Element> = try await self.session.begin(query: command,
            against: database,
            over: self.pinned,
            on: preference,
            by: deadlines)
        do
        {
            let success:Success = try await consumer(batches)
            await batches.destroy()
            return success
        }
        catch let error
        {
            await batches.destroy()
            throw error
        }
    }
}
