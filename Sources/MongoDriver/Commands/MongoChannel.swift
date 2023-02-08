import BSON
import BSONDSL
import MongoChannel
import MongoWire
import NIOCore

extension MongoChannel
{
    /// Encodes the given command to a document, sends it over this channel and
    /// awaits its reply.
    ///
    /// If the deadline has already passed before the command can be encoded, this
    /// method will throw a ``TimeoutError``, but the channel will not be closed.
    /// In all other scenarios, the channel will be closed on timeout.
    @inlinable public
    func run<Command>(command:__owned Command,
        against database:Command.Database,
        labels:Mongo.SessionLabels? = nil,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.Reply
        where Command:MongoCommand
    {
        //  Never append `maxTimeMS` to commands run directly on a channel.
        if  let command:MongoWire.Message<[UInt8]>.Sections = command.encode(
                database: database,
                labels: labels,
                timed: false,
                by: deadline)
        {
            return try .init(message: try await self.run(command: command, by: deadline))
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
