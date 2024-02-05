import BSON
import MongoExecutor
import MongoWire

extension MongoExecutor
{
    /// Encodes the given command to a document, adding the given database
    /// as a field with the key `"$db"`, sends it over this channel, and
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
        let sections:Mongo.WireMessage.Sections

        guard now < deadline
        else
        {
            throw Mongo.DriverTimeoutError.init()
        }


        var document:BSON.Document = .init(encoding: command)
            document[BSON.Key.self]["$db"] = database.name

        sections = .init(body: document)

        return try .init(message: try await self.request(
            sections: sections,
            deadline: deadline))
    }
}
