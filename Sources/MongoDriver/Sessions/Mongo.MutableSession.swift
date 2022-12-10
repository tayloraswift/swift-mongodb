import MongoWire
import NIOCore

extension Mongo
{
    public
    struct MutableSession
    {
        private
        let connection:Connection
        private
        let manager:SessionManager

        private
        init(connection:Connection, manager:SessionManager)
        {
            self.connection = connection
            self.manager = manager
        }
    }
}
extension Mongo.MutableSession
{
    public
    init(on deployment:Mongo.Deployment) async
    {
        let (context, metadata):(Mongo.SessionContext, Mongo.SessionMetadata) =
            await deployment.session(on: .master)
        self.init(connection: context.connection, manager: .init(metadata: metadata,
            deployment: deployment))
    }
}
extension Mongo.MutableSession:Identifiable
{
    public
    var id:Mongo.SessionIdentifier
    {
        self.manager.metadata.id
    }
}
extension Mongo.MutableSession
{
    /// Runs a session command against the ``Mongo/Database/.admin`` database.
    public
    func run<Command>(command:Command) async throws -> Command.Response
        where Command:MongoSessionCommand
    {
        let touched:ContinuousClock.Instant = .now
        let message:MongoWire.Message<ByteBufferView> = try await self.connection.run(
            command: command, against: .admin,
            transaction: nil,
            session: self.id)
        self.manager.metadata.state.touched = touched
        return try Command.decode(message: message)
    }
    
    /// Runs a session command against the specified database.
    public
    func run<Command>(command:Command, 
        against database:Mongo.Database) async throws -> Command.Response
        where Command:MongoDatabaseCommand
    {
        let touched:ContinuousClock.Instant = .now
        let message:MongoWire.Message<ByteBufferView> = try await self.connection.run(
            command: command, against: database,
            transaction: nil,
            session: self.id)
        self.manager.metadata.state.touched = touched
        return try Command.decode(message: message)
    }
}
