import BSONEncoding
import MongoExecutor
import MongoWire

extension MongoExecutor
{
    /// Encodes the given command to a document, adding the given database
    /// as a field with the key [`"$db"`](), sends it over this channel, and
    /// awaits its reply.
    ///
    /// If the deadline has already passed before the command can be encoded,
    /// this method will throw a ``TimeoutError``, but the channel will not
    /// be closed. In all other scenarios, the channel will be closed on
    /// timeout.
    func run<Command>(command:__owned Command,
        against database:Mongo.Database,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.Reply
        where Command:BSONDocumentEncodable
    {
        let now:ContinuousClock.Instant = .now
        let sections:MongoWire.Message<[UInt8]>.Sections

        if now < deadline
        {
            var document:BSON.Document = .init(encoding: command)
                document["$db"] = database.name
            sections = .init(body: .init(document))
        }
        else
        {
            throw Mongo.TimeoutError.driver(sent: false)
        }

        switch await self.request(sections: sections, deadline: deadline)
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
