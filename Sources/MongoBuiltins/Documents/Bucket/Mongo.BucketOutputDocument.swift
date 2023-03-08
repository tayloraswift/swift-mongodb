import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct BucketOutputDocument:Sendable
    {
        public
        var document:BSON.Document

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.document = .init(bytes: bytes)
        }
    }
}
extension Mongo.BucketOutputDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
            self.document.push(key, value)
        }
    }
}
