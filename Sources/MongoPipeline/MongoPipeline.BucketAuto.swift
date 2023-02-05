import BSONDecoding
import BSONEncoding

extension MongoPipeline
{
    @frozen public
    struct BucketAuto:Sendable
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
extension MongoPipeline.BucketAuto:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoPipeline.BucketAuto:BSONEncodable
{
}
extension MongoPipeline.BucketAuto:BSONDecodable
{
}

extension MongoPipeline.BucketAuto
{
    @inlinable public
    subscript<Encodable>(key:MongoPipeline.Bucket.By) -> Encodable?
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
    @inlinable public
    subscript(key:Buckets) -> Int?
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
    subscript(key:Granularity) -> PreferredNumbers?
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
    subscript(key:MongoPipeline.Bucket.Output) -> MongoPipeline.Bucket.OutputDocument?
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
