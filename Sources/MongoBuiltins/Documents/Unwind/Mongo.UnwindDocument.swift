import BSONEncoding
import MongoExpressions

extension Mongo
{
    @frozen public
    struct UnwindDocument:MongoDocumentDSL, Sendable
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
extension Mongo.UnwindDocument
{
    @inlinable public
    subscript<KeyPath>(key:Path) -> KeyPath?
        where KeyPath:MongoKeyPathEncodable
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
    @inlinable public
    subscript(key:ArrayIndexAs) -> BSON.Key?
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
    @inlinable public
    subscript(key:PreserveNullAndEmptyArrays) -> Bool?
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
