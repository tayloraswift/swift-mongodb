import BSONEncoding
import MongoExecutor
import MongoWire

extension MongoExecutor
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
        where Command:MongoCommand & BSONDocumentEncodable
    {
        guard   let command:MongoWire.Message<[UInt8]>.Sections = command.encode(
                    database: database,
                    by: deadline)
        else
        {
            throw Mongo.TimeoutError.driver(sent: false)
        }

        switch await self.request(deadline: deadline, message: command)
        {
        case .success(let message):
            return try .init(message: message)
        
        case .failure(.timeout):
            throw Mongo.TimeoutError.driver(sent: true)
        
        case .failure(let error):
            throw error
        }
    }
}
