import Durations

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
        @usableFromInline
        let cluster:Mongo.Cluster
        @usableFromInline
        let state:State

        public
        let id:SessionIdentifier

        init(on cluster:Mongo.Cluster,
            metadata:SessionMetadata,
            id:SessionIdentifier)
        {
            self.state = .init(metadata)

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
    func run<Command>(command:Command, against database:Command.Database,
        over connection:Mongo.Connection,
        on preference:Mongo.ReadPreference,
        by deadline:ContinuousClock.Instant) async throws -> Command.Response
        where Command:MongoCommand
    {
        let labels:Mongo.SessionLabels = .init(clusterTime: self.cluster.time,
            readPreference: preference,
            readConcern: (command as? any MongoReadCommand).map
            {
                .init(level: $0.readLevel, after: self.state.lastOperationTime)
            },
            transaction: self.state.metadata.transaction,
            session: self.id)
        
        let sent:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await connection.channel.run(command: command,
            against: database,
            labels: labels,
            by: deadline)

        self.state.update(touched: sent, operationTime: reply.operationTime)
        self.cluster.push(time: reply.clusterTime)

        return try Command.decode(reply: try reply.result.get())
    }
    /// Runs a command against the specified database, on a server selected according
    /// to the specified read preference.
    ///
    /// -   Parameters:
    ///     -   command:
    ///         The command to run.
    ///     -   database:
    ///         The database to run the command against.
    ///     -   preference:
    ///         The read preference to use for server selection.
    ///     -   deadline:
    ///         A deadline used to enforce operation timeouts. If [`nil`](),
    ///         the default driver connection timeout will also be used as
    ///         the timeout for the entire operation.
    ///     -   started:
    ///         The time that is considered when the operation was “started”,
    ///         and which computed deadlines are relative to.
    @inlinable public
    func run<Command>(command:Command, against database:Command.Database,
        on preference:Mongo.ReadPreference = .primary,
        by deadline:ContinuousClock.Instant? = nil,
        started:ContinuousClock.Instant = .now) async throws -> Command.Response
        where Command:MongoCommand
    {
        let connect:Mongo.ConnectionDeadline = self.cluster.timeout.deadline(from: started,
            clamping: deadline)
        let connections:Mongo.ConnectionPool = try await self.cluster.pool(
            preference: preference,
            by: connect)
        let connection:Mongo.Connection = try await connections.create(
            by: connect)
        defer
        {
            connections.destroy(connection)
        }
        return try await self.run(command: command, against: database,
            over: connection,
            on: preference,
            by: deadline ?? connect.instant)
    }
}
extension Mongo.Session
{
    @inlinable public
    func run<Query, Success>(query:Query, against database:Query.Database,
        on preference:Mongo.ReadPreference = .primary,
        by deadline:ContinuousClock.Instant? = nil,
        started:ContinuousClock.Instant = .now,
        with consumer:(Mongo.Batches<Query.Element>) async throws -> Success)
        async throws -> Success
        where Query:MongoQuery
    {
        let connect:Mongo.ConnectionDeadline = self.cluster.timeout.deadline(from: started,
            clamping: deadline)
        let connections:Mongo.ConnectionPool = try await self.cluster.pool(
            preference: preference,
            by: connect)
        let connection:Mongo.Connection = try await connections.create(
            by: connect)
        
        let deadline:ContinuousClock.Instant = deadline ?? connect.instant
        let batches:Mongo.Batches<Query.Element> = .create(preference: preference,
            lifespan: query.tailing.map { .iterable($0.timeout) } ?? .expires(deadline),
            timeout: .init(
                milliseconds: self.cluster.timeout.milliseconds),
            initial: try await self.run(command: query,
                against: database,
                over: connection,
                on: preference,
                by: deadline),
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
