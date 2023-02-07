import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct BucketOutputDocument:Sendable
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
extension Mongo.BucketOutputDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.BucketOutputDocument:BSONEncodable
{
}
extension Mongo.BucketOutputDocument:BSONDecodable
{
}

extension Mongo.BucketOutputDocument
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
}
