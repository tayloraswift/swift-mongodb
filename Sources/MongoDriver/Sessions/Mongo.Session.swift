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
    func run<Command>(unsafe command:Command,
        against database:Mongo.Database,
        on selection:Mongo.Selection)
        async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        try await self.run(unsafe: command, against: database, on: selection,
            clusterTime: await self.cluster.time)
    }
    
    @inlinable public
    func run<Command>(unsafe command:Command,
        against database:Mongo.Database,
        on selection:Mongo.Selection,
        clusterTime:Mongo.ClusterTime)
        async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        let labeled:Mongo.Labeled<Command> = .init(clusterTime: clusterTime,
            readPreference: selection.preference,
            readConcern: (command as? any MongoReadCommand).map
            {
                .init(level: $0.readLevel, after: self.state.lastOperationTime)
            },
            transaction: self.state.metadata.transaction,
            session: self.id,
            command: command)
        
        let sent:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await selection.channel.run(labeled: labeled,
            against: database)

        self.state.update(touched: sent, operationTime: reply.operationTime)
        self.cluster.push(time: reply.clusterTime)

        return try Command.decode(reply: try reply.result.get())
    }

    /// Runs a session command against the ``Mongo/Database/.admin`` database.
    @inlinable public
    func run<Command>(command:Command,
        on preference:Mongo.ReadPreference = .primary) async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        let deadline:ContinuousClock.Instant = .now.advanced(by: self.connectionTimeout)
        let (clusterTime, selection):(Mongo.ClusterTime, Mongo.Selection) =
            try await self.cluster.select(preference: preference, by: deadline)
        
        return try await self.run(unsafe: command, against: .admin, on: selection,
            clusterTime: clusterTime)
    }
    
    /// Runs a session command against the specified database.
    @inlinable public
    func run<Command>(command:Command,
        against database:Mongo.Database,
        on preference:Mongo.ReadPreference = .primary)
        async throws -> Command.Response
        where Command:MongoSessionCommand & MongoDatabaseCommand
    {
        let deadline:ContinuousClock.Instant = .now.advanced(by: self.connectionTimeout)
        let (clusterTime, selection):(Mongo.ClusterTime, Mongo.Selection) =
            try await self.cluster.select(preference: preference, by: deadline)
        
        return try await self.run(unsafe: command, against: database, on: selection,
            clusterTime: clusterTime)
    }
}
