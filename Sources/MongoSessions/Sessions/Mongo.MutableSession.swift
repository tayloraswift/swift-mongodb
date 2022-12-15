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
        private
        let monitor:Mongo.TopologyMonitor

        @usableFromInline
        var metadata:SessionMetadata
        private
        let medium:SessionMedium
        public
        let id:SessionIdentifier


        init(monitor:Mongo.TopologyMonitor, context:SessionContext, medium:SessionMedium)
        {
            self.monitor = monitor
            self.metadata = context.metadata
            self.medium = medium
            self.id = context.id
        }
    }
}
extension Mongo.MutableSession:MongoSessionType
{
    static
    let medium:Mongo.SessionMediumSelector = .master

    var context:Mongo.SessionContext
    {
        (self.id, self.metadata)
    }
}
extension Mongo.MutableSession
{
    @usableFromInline
    var connection:Mongo.Connection
    {
        self.medium.connection
    }
    private
    var _time:UInt64?
    {
        let time:UInt64 = self.monitor.time.load(ordering: .relaxed)
        return time == 0 ? nil : time
    }
}

extension Mongo.MutableSession
{
    /// Runs a session command against the ``Mongo/Database/.admin`` database.
    @inlinable public mutating
    func run<Command>(command:Command) async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        let touched:ContinuousClock.Instant = .now
        let message:MongoWire.Message<ByteBufferView> = try await self.connection.run(
            command: command, against: .admin,
            transaction: nil,
            session: self.id)
        self.metadata.touched = touched
        return try Command.decode(message: message)
    }
    
    /// Runs a session command against the specified database.
    @inlinable public mutating
    func run<Command>(command:Command, 
        against database:Mongo.Database) async throws -> Command.Response
        where Command:MongoSessionCommand & MongoDatabaseCommand
    {
        let touched:ContinuousClock.Instant = .now
        let message:MongoWire.Message<ByteBufferView> = try await self.connection.run(
            command: command, against: database,
            transaction: nil,
            session: self.id)
        self.metadata.touched = touched
        return try Command.decode(message: message)
    }
}
