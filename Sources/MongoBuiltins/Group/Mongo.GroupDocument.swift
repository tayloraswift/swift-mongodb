import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct GroupDocument:Sendable
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
extension Mongo.GroupDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.GroupDocument:BSONEncodable
{
}
extension Mongo.GroupDocument:BSONDecodable
{
}

extension Mongo.GroupDocument
{
    @inlinable public
    subscript(key:String) -> Mongo.Accumulator?
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
    subscript<Encodable>(key:ID) -> Encodable?
        where Encodable:MongoExpressionEncodable
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
