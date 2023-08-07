import BSONEncoding
import MongoSchema

extension Mongo
{
    @frozen public
    struct KillCursors:Sendable
    {
        public
        let collection:Collection
        public
        let cursors:[CursorIdentifier]

        @inlinable public
        init(_ collection:Collection, cursors:[CursorIdentifier])
        {
            self.collection = collection
            self.cursors = cursors
        }
    }
}
extension Mongo.KillCursors:MongoCommand
{
    /// The string [`"killCursors"`]().
    @inlinable public static
    var type:Mongo.CommandType { .killCursors }

    public
    typealias Response = Mongo.KillCursorsResponse

    public
    var fields:BSON.Document
    {
        Self.type(self.collection)
        {
            $0["cursors"] = self.cursors
        }
    }
}
extension Mongo.KillCursors:MongoTransactableCommand
{
}
