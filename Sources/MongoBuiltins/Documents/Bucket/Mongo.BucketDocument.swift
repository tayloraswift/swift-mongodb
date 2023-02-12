import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct BucketDocument:Sendable
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
extension Mongo.BucketDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.BucketDocument:BSONEncodable
{
}
extension Mongo.BucketDocument:BSONDecodable
{
}

extension Mongo.BucketDocument
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
    subscript(key:Output) -> Mongo.BucketOutputDocument?
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
