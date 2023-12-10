import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct GroupDocument:MongoDocumentDSL, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
    }
}
extension Mongo.GroupDocument
{
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Mongo.Accumulator?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
    @inlinable public
    subscript<Encodable>(key:ID) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(key, value)
        }
    }
}
