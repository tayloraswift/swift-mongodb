extension Mongo
{
    /// Tracks a session on a MongoDB server. Sessions have reference semantics.
    ///
    /// Sessions are not ``Sendable``, because their purpose is to provide a
    /// guarantee of causual consistency between asynchronous operations.
    /// (“Read your writes”.) Therefore using the same session from
    /// concurrently-executing code without some other means of regulating
    /// command dispatch does not make sense.
    ///
    /// Most of the time when you want to perform concurrent operations
    /// on a database, you want each task to checkout its own session from a
    /// ``SessionPool``, which is ``Sendable``.
    public
    struct Session:Identifiable
    {
        public
        let connectionTimeout:Duration
        public
        let cluster:Mongo.Cluster
        @usableFromInline
        let state:State

        public
        let id:SessionIdentifier

        init(on cluster:Mongo.Cluster,
            connectionTimeout:Duration,
            metadata:SessionMetadata,
            id:SessionIdentifier)
        {
            self.state = .init(metadata)

            self.connectionTimeout = connectionTimeout
            self.cluster = cluster
            self.id = id
        }
    }
}
@available(*, unavailable, message: "sessions have reference semantics")
extension Mongo.Session:Sendable
{
}
extension Mongo.Session
{
    @inlinable public
    func deadline(from start:ContinuousClock.Instant = .now) -> ContinuousClock.Instant
    {
        start.advanced(by: self.connectionTimeout)
    }
}
extension Mongo.Session
{    
    @inlinable public
    func run<Command>(command:Command, against database:Command.Database,
        over connection:Mongo.Connection,
        on preference:Mongo.ReadPreference) async throws -> Command.Response
        where Command:MongoCommand
    {
        let labeled:Mongo.Labeled<Command> = .init(clusterTime: self.cluster.time,
            readPreference: preference,
            readConcern: (command as? any MongoReadCommand).map
            {
                .init(level: $0.readLevel, after: self.state.lastOperationTime)
            },
            transaction: self.state.metadata.transaction,
            session: self.id,
            command: command)
        
        let sent:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await connection.channel.run(labeled: labeled,
            against: database)

        self.state.update(touched: sent, operationTime: reply.operationTime)
        self.cluster.push(time: reply.clusterTime)

        return try Command.decode(reply: try reply.result.get())
    }
    
    @inlinable public
    func run<Command>(command:Command, against database:Command.Database,
        on preference:Mongo.ReadPreference = .primary) async throws -> Command.Response
        where Command:MongoCommand
    {
        let deadline:ContinuousClock.Instant = self.deadline()
        let connections:Mongo.ConnectionPool = try await self.cluster.pool(
            preference: preference,
            by: deadline)
        let connection:Mongo.Connection = try await connections.create(
            by: deadline)
        defer
        {
            connections.destroy(connection)
        }
        return try await self.run(command: command, against: database,
            over: connection,
            on: preference)
    }
}
extension Mongo.Session
{
    @inlinable public
    func run<Query, Success>(query:Query, against database:Query.Database,
        on preference:Mongo.ReadPreference = .primary,
        with consumer:(Mongo.Batches<Query.Element>) async throws -> Success)
        async throws -> Success
        where Query:MongoQuery
    {
        let deadline:ContinuousClock.Instant = self.deadline()

        let connections:Mongo.ConnectionPool = try await self.cluster.pool(
            preference: preference,
            by: deadline)
        let connection:Mongo.Connection = try await connections.create(
            by: deadline)
        
        let batches:Mongo.Batches<Query.Element> = .create(preference: preference,
            initial: try await self.run(command: query,
                against: database,
                over: connection,
                on: preference),
            timeout: query.tailing?.timeout,
            stride: query.stride,
            pinned: (connection, self),
            pool: connections)
        
        do
        {
            let success:Success = try await consumer(batches)
            try await batches.destroy()
            return success
        }
        catch let error
        {
            try await batches.destroy()
            throw error
        }
    }
}
extension Mongo.Session
{
    /// Runs a ``RefreshSessions`` command. Calling this convenience method is equivalent
    /// to constructing a ``RefreshSessions`` instance with this session’s ``id`` and
    /// running it manually.
    public
    func refresh(on preference:Mongo.ReadPreference = .primary) async throws
    {
        try await self.run(command: Mongo.RefreshSessions.init(self.id),
            against: .admin,
            on: preference)
    }
}
