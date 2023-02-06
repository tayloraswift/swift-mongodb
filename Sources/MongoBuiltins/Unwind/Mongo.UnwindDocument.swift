import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct UnwindDocument:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension Mongo.UnwindDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
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
    subscript<FieldPath>(key:Path) -> FieldPath? where FieldPath:MongoExpressionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value
        }
    }
}
