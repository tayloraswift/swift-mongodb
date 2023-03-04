import BSONEncoding
import MongoExecutor
import MongoWire

extension MongoExecutor
{
    /// Encodes the given command to a document, adding the given database
    /// as a field with the key [`"$db"`](), sends it over this channel, and
    /// awaits its reply.
    ///
    /// If the deadline passes before this function can start executing, this
    /// method will not close the channel or send anything over it.
    ///
    /// If the task the caller is running on gets cancelled before this
    /// function can start executing, this method will not close the channel
    /// or send anything over it.
    ///
    /// In all other scenarios, the channel will be closed on failure.
    func run<Command>(command:__owned Command,
        against database:Mongo.Database,
        by deadline:ContinuousClock.Instant) async throws -> Mongo.Reply
        where Command:BSONDocumentEncodable
    {
        try Task.checkCancellation()
        
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
            throw Mongo.TimeoutError.driver(written: false)
        }

        switch await self.request(sections: sections, deadline: deadline)
        {
        case .success(let message):
            return try .init(message: message)

        case .failure(let error):
            throw try Mongo.NetworkError.init(triaging: error)
        }
    }
}
