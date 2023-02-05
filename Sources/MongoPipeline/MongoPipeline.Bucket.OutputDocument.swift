import BSONDecoding
import BSONEncoding

extension MongoPipeline.Bucket
{
    @frozen public
    struct OutputDocument:Sendable
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
extension MongoPipeline.Bucket.OutputDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoPipeline.Bucket.OutputDocument:BSONEncodable
{
}
extension MongoPipeline.Bucket.OutputDocument:BSONDecodable
{
}

extension MongoPipeline.Bucket.OutputDocument
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
}
