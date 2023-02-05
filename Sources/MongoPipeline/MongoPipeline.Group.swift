import BSONDecoding
import BSONEncoding

extension MongoPipeline
{
    @frozen public
    struct Group:Sendable
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
extension MongoPipeline.Group:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoPipeline.Group:BSONEncodable
{
}
extension MongoPipeline.Group:BSONDecodable
{
}

extension MongoPipeline.Group
{
    @inlinable public
    subscript(key:String) -> MongoAccumulator?
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
