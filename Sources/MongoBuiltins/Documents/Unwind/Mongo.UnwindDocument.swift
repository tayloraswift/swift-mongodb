import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct UnwindDocument:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.UnwindDocument:BSONEncodable
{
}
extension Mongo.UnwindDocument:BSONDecodable
{
}

extension Mongo.UnwindDocument
{
    @inlinable public
    subscript<FieldPath>(key:Path) -> FieldPath?
        where FieldPath:MongoFieldPathEncodable
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
    subscript(key:ArrayIndexAs) -> String?
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
