import BSONDecoding
import BSONEncoding
import Durations

extension Mongo
{
    @frozen public
    struct GetMore<Element>:Sendable where Element:BSONDocumentDecodable
    {
        public
        let cursor:CursorIdentifier
        public
        let collection:Collection
        public
        let timeout:MaxTime?
        public
        let count:Int?

        @inlinable public
        init(cursor:CursorIdentifier, collection:Collection,
            timeout:MaxTime?,
            count:Int?)
        {
            self.cursor = cursor
            self.collection = collection
            self.timeout = timeout
            self.count = count
        }
    }
}
extension Mongo.GetMore:MongoCommand
{
    /// The string [`"getMore"`]().
    @inlinable public static
    var name:String
    {
        "getMore"
    }

    public
    typealias Response = Mongo.Cursor<Element>

    public
    var fields:BSON.Document
    {
        .init
        {
            $0[Self.name] = self.cursor
            $0["collection"] = self.collection
            $0["batchSize"] = self.count
        }
    }
}
extension Mongo.GetMore:MongoTransactableCommand
{
}
@available(*, unavailable, message: "GetMore cannot use implicit sessions.")
extension Mongo.GetMore:MongoImplicitSessionCommand
{
}
