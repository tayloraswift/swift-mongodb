import MongoWire
import NIOCore

extension Mongo
{
    /// Tracks a session on a MongoDB server that can mutate database state.
    ///
    /// Running any session operation, even read-only operations, mutates
    /// local session metadata. Therefore the `run(command:)` methods are
    /// still `mutating`, even when running a command that does not mutate
    /// conceptual database state.
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
        // TODO: implement time gossip
        let monitor:Mongo.TopologyMonitor

        @usableFromInline
        @Boxed<SessionMetadata>
        var metadata:SessionMetadata

        private
        let medium:SessionMedium
        public
        let id:SessionIdentifier

        init(monitor:Mongo.TopologyMonitor,
            metadata:SessionMetadata,
            medium:SessionMedium,
            id:SessionIdentifier)
        {
            self._metadata = .init(wrappedValue: metadata)

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
}
extension Mongo.MutableSession
{
    @usableFromInline
    var connection:Mongo.Connection
    {
        self.medium.connection
    }
    @usableFromInline
    var labels:Mongo.TransactionLabels
    {
        .init(transaction: self.metadata.transaction, session: self.id)
    }
}

extension Mongo.MutableSession
{
    /// Runs a session command against the ``Mongo/Database/.admin`` database.
    @inlinable public
    func run<Command>(command:Command) async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        let touched:ContinuousClock.Instant = .now
        let message:MongoWire.Message<ByteBufferView> = try await self.connection.run(
            command: command, against: .admin,
            labels: self.labels)
        self.metadata.touched = touched
        return try Command.decode(message: message)
    }
    
    /// Runs a session command against the specified database.
    @inlinable public
    func run<Command>(command:Command, 
        against database:Mongo.Database) async throws -> Command.Response
        where Command:MongoSessionCommand & MongoDatabaseCommand
    {
        let touched:ContinuousClock.Instant = .now
        let message:MongoWire.Message<ByteBufferView> = try await self.connection.run(
            command: command, against: database,
            labels: self.labels)
        self.metadata.touched = touched
        return try Command.decode(message: message)
    }
}
