import MongoWire
import NIOCore

extension Mongo
{
    public final
    class MutableSession:Identifiable
    {
        public
        let id:SessionIdentifier
        private
        var metadata:SessionMetadata
        private
        let medium:SessionMedium
        // TODO: implement time gossip
        private
        let pool:Mongo.SessionPool

        private
        init(on pool:Mongo.SessionPool,
            metadata:SessionMetadata,
            medium:SessionMedium,
            id:SessionIdentifier)
        {
            self.id = id
            self.metadata = metadata
            self.medium = medium
            self.pool = pool
        }

        deinit
        {
            Task.init
            {
                [id, metadata, medium, pool] in
                await pool.checkin(session: .init(id: id, medium: medium, metadata: metadata))
            }
        }
    }
}
extension Mongo.MutableSession
{
    private convenience
    init(on pool:Mongo.SessionPool, context:Mongo.SessionContext)
    {
        self.init(on: pool, metadata: context.metadata,
            medium: context.medium,
            id: context.id)
    }
    public convenience
    init(on pool:Mongo.SessionPool) async throws
    {
        self.init(on: pool, context: await pool.checkout(selector: .master))
    }
}
extension Mongo.MutableSession
{
    private
    var connection:Mongo.Connection
    {
        self.medium.connection
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
        self.metadata.touched = touched
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
        self.metadata.touched = touched
        return try Command.decode(message: message)
    }
}
