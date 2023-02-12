import BSONEncoding

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
        init(_ cursors:[CursorIdentifier], collection:Collection)
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
    var name:String
    {
        "killCursors"
    }
    
    public
    typealias Response = Mongo.KillCursorsResponse

    public
    var fields:BSON.Fields
    {
        .init
        {
            $0[Self.name] = self.collection
            $0["cursors"] = self.cursors
        }
    }
}
extension Mongo.KillCursors:MongoTransactableCommand
{
}
