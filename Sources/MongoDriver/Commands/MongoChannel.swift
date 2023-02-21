import BSON
import BSONStream
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
    func run<Command>(command:__owned Command,
        against database:Command.Database,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.Reply
        where Command:MongoChannelCommand
    {
        guard   let command:MongoWire.Message<[UInt8]>.Sections = command.encode(
                    database: database,
                    by: deadline)
        else
        {
            throw Mongo.TimeoutError.driver(sent: false)
        }

        switch await self.run(command: command, by: deadline)
        {
        case .success(let message):
            return try .init(message: message)
        
        case .failure(.network(error: let error)):
            throw error
        
        case .failure(.timeout):
            throw Mongo.TimeoutError.driver(sent: true)
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
            by: deadline.instant)())
    }
    /// Runs an authentication command against the specified `database`,
    /// and decodes its response.
    func run(saslContinue command:__owned Mongo.SASLContinue,
        against database:Mongo.Database,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.SASLResponse
    {
        try .init(bson: try await self.run(command: command, against: database,
            by: deadline.instant)())
    }
    /// Runs a ``Mongo/Hello`` command, and decodes a subset of its response
    /// suitable for authentication purposes.
    func run(hello command:__owned Mongo.Hello,
        by deadline:Mongo.ConnectionDeadline) async throws -> Mongo.Authentication.HelloResponse
    {
        try .init(bson: try await self.run(command: command, against: .admin,
            by: deadline.instant)())
    }
}
