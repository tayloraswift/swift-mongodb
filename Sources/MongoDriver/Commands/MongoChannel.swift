import BSON
import BSONDSL
import MongoChannel
import MongoWire
import NIOCore

extension MongoChannel
{
    /// Encodes the given command to a document, sends it over this channel and
    /// awaits its reply.
    @inlinable public
    func run<Command>(command:__owned Command,
        against database:Command.Database,
        labels:Mongo.SessionLabels? = nil,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.Reply
        where Command:MongoCommand
    {
        if  let message:MongoWire.Message<ByteBufferView> = try await self.run(
                command: .init { command.encode(to: &$0, database: database, labels: labels) },
                by: deadline)
        {
            return try .init(message: message)
        }
        else
        {
            throw MongoChannel.TimeoutError.init()
        }
    }
}
extension MongoChannel
{
    /// Runs an authentication command against the specified `database`,
    /// and decodes its response.
    func run(saslStart command:__owned Mongo.SASLStart,
        against database:Mongo.Database,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.SASLResponse
    {
        try .init(bson: try await self.run(command: command, against: database,
            by: deadline.instant).result.get())
    }
    /// Runs an authentication command against the specified `database`,
    /// and decodes its response.
    func run(saslContinue command:__owned Mongo.SASLContinue,
        against database:Mongo.Database,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.SASLResponse
    {
        try .init(bson: try await self.run(command: command, against: database,
            by: deadline.instant).result.get())
    }
    /// Runs a ``Mongo/Hello`` command, and decodes its response.
    func run(hello command:__owned Mongo.Hello,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.HelloResponse
    {
        try .init(bson: try await self.run(command: command, against: .admin,
            by: deadline.instant).result.get())
    }
}
