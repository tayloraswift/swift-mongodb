import MongoChannel
import MongoWire
import NIOCore

extension Mongo
{
    /// Tracks a session on a MongoDB server that can mutate database state.
    /// Sessions have reference semantics.
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
    struct MutableSession:Identifiable
    {
        @usableFromInline
        let state:State
        // TODO: implement time gossip
        let monitor:Mongo.Monitor
        private
        let medium:SessionMedium
        public
        let id:SessionIdentifier

        init(monitor:Mongo.Monitor,
            metadata:SessionMetadata,
            medium:SessionMedium,
            id:SessionIdentifier)
        {
            self.state = .init(metadata)

            self.monitor = monitor
            self.medium = medium
            self.id = id
        }
    }
}
@available(*, unavailable, message: "sessions have reference semantics")
extension Mongo.MutableSession:Sendable
{
}
extension Mongo.MutableSession:MongoConcurrencyDomain
{
    static
    let medium:Mongo.SessionMediumSelector = .master

    @usableFromInline
    var metadata:Mongo.SessionMetadata
    {
        self.state.metadata
    }
}

extension Mongo.MutableSession
{
    @inlinable public
    func label<Command>(command:Command) -> Mongo.SessionLabeled<Command>
        where Command:MongoSessionCommand
    {
        .init(readConcern: (command as? any MongoReadCommand).map
            {
                .init(level: $0.readLevel, after: self.state.lastOperationTime)
            },
            transaction: self.metadata.transaction,
            session: self.id,
            command: command)
    }
}
extension Mongo.MutableSession
{
    @usableFromInline
    var channel:MongoChannel
    {
        self.medium.channel
    }

    @inlinable public
    func time<Command>(command:Command,
        operation:(Mongo.SessionLabeled<Command>) async throws -> Mongo.Reply)
        async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        let started:ContinuousClock.Instant = .now
        let reply:Mongo.Reply = try await operation(self.label(command: command))
        self.state.update(touched: started, operationTime: reply.operationTime)
        // TODO: clusterTime gossip
        return try Command.decode(reply: try reply.result.get())
    }

    /// Runs a session command against the ``Mongo/Database/.admin`` database.
    @inlinable public
    func run<Command>(command:Command) async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        try await self.time(command: command)
        {
            try await self.channel.run(labeled: $0, against: .admin)
        }
    }
    
    /// Runs a session command against the specified database.
    @inlinable public
    func run<Command>(command:Command, 
        against database:Mongo.Database) async throws -> Command.Response
        where Command:MongoSessionCommand & MongoDatabaseCommand
    {
        try await self.time(command: command)
        {
            try await self.channel.run(labeled: $0, against: database)
        }
    }
}
