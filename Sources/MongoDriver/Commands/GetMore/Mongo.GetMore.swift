import BSONEncoding
import Durations
import MongoSchema

extension Mongo
{
    @frozen public
    struct GetMore<Element>:Sendable where Element:MongoDecodable
    {
        public
        let cursor:CursorIdentifier
        public
        let collection:Collection
        public
        let timeout:OperationTimeout?
        public
        let count:Int?

        @inlinable public
        init(cursor:CursorIdentifier, collection:Collection,
            timeout:OperationTimeout? = nil,
            count:Int? = nil)
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
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["getMore"] = self.cursor
        bson["collection"] = self.collection
        bson["maxTimeMS"] = self.timeout?.milliseconds
        bson["batchSize"] = self.count
    }

    public
    typealias Response = Mongo.Cursor<Element>
}
extension Mongo.GetMore:MongoTransactableCommand
{
}
