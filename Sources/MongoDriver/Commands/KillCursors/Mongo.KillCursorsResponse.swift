import BSON
import MongoCommands

extension Mongo
{
    public
    struct KillCursorsResponse:Sendable
    {
        public
        let alive:[CursorIdentifier]
        public
        let killed:[CursorIdentifier]
        public
        let notFound:[CursorIdentifier]
        public
        let unknown:[CursorIdentifier]

        public
        init(alive:[CursorIdentifier],
            killed:[CursorIdentifier],
            notFound:[CursorIdentifier],
            unknown:[CursorIdentifier])
        {
            self.alive = alive
            self.killed = killed
            self.notFound = notFound
            self.unknown = unknown
        }
    }
}
extension Mongo.KillCursorsResponse:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key>) throws
    {
        self.init(
            alive: try bson["cursorsAlive"].decode(to: [Mongo.CursorIdentifier].self),
            killed: try bson["cursorsKilled"].decode(to: [Mongo.CursorIdentifier].self),
            notFound: try bson["cursorsNotFound"].decode(to: [Mongo.CursorIdentifier].self),
            unknown: try bson["cursorsUnknown"].decode(to: [Mongo.CursorIdentifier].self))
    }
}
