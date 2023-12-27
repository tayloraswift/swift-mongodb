import BSON
import Durations
import MongoABI
import MongoCommands

extension Mongo
{
    @frozen public
    struct GetMore<Element>:Sendable where Element:BSONDecodable & Sendable
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
extension Mongo.GetMore:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .getMore }

    public
    typealias Response = Mongo.CursorBatch<Element>

    public
    var fields:BSON.Document
    {
        Self.type(self.cursor)
        {
            $0["collection"] = self.collection
            $0["batchSize"] = self.count
        }
    }
}
extension Mongo.GetMore:Mongo.TransactableCommand
{
}
@available(*, unavailable, message: "GetMore cannot use implicit sessions.")
extension Mongo.GetMore:Mongo.ImplicitSessionCommand
{
}
