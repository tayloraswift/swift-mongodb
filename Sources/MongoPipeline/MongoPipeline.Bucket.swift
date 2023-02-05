import BSONDecoding
import BSONEncoding

extension MongoPipeline
{
    @frozen public
    struct Bucket:Sendable
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
extension MongoPipeline.Bucket:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoPipeline.Bucket:BSONEncodable
{
}
extension MongoPipeline.Bucket:BSONDecodable
{
}

extension MongoPipeline.Bucket
{
    @inlinable public
    subscript<Encodable>(key:Argument) -> Encodable? where Encodable:MongoExpressionEncodable
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
    subscript<Encodable>(key:By) -> Encodable? where Encodable:MongoExpressionEncodable
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
    subscript(key:Output) -> MongoPipeline.Bucket.OutputDocument?
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
