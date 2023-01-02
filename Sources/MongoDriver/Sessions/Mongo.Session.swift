import MongoChannel
import MongoWire
import NIOCore

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
    func time<Command>(command:Command, on preference:Mongo.ReadPreference,
        operation:(MongoChannel, Mongo.Labeled<Command>) async throws -> Mongo.Reply)
        async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        let started:ContinuousClock.Instant = .now

        let medium:Mongo.ReadMedium = try await self.cluster.medium(to: preference,
            by: .now.advanced(by: self.connectionTimeout))
        
        let labeled:Mongo.Labeled<Command> = .init(clusterTime: medium.clusterTime,
            readPreference: preference,
            readConcern: (command as? any MongoReadCommand).map
            {
                .init(level: $0.readLevel, after: self.state.lastOperationTime)
            },
            transaction: self.state.metadata.transaction,
            session: self.id,
            command: command)
        
        let reply:Mongo.Reply = try await operation(medium.channel, labeled)

        self.state.update(touched: started, operationTime: reply.operationTime)
        self.cluster.push(time: reply.clusterTime)

        return try Command.decode(reply: try reply.result.get())
    }

    /// Runs a session command against the ``Mongo/Database/.admin`` database.
    @inlinable public
    func run<Command>(command:Command,
        on preference:Mongo.ReadPreference = .primary) async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        try await self.time(command: command, on: preference)
        {
            try await $0.run(labeled: $1, against: .admin)
        }
    }
    
    /// Runs a session command against the specified database.
    @inlinable public
    func run<Command>(command:Command,
        against database:Mongo.Database,
        on preference:Mongo.ReadPreference = .primary)
        async throws -> Command.Response
        where Command:MongoSessionCommand & MongoDatabaseCommand
    {
        try await self.time(command: command, on: preference)
        {
            try await $0.run(labeled: $1, against: database)
        }
    }
}
