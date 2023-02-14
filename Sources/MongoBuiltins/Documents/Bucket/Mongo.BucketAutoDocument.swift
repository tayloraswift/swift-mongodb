import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct BucketAutoDocument:Sendable
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
extension Mongo.BucketAutoDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.BucketAutoDocument:BSONEncodable
{
}
extension Mongo.BucketAutoDocument:BSONDecodable
{
}

extension Mongo.BucketAutoDocument
{
    @inlinable public
    subscript<Encodable>(key:Mongo.BucketDocument.By) -> Encodable?
        where Encodable:MongoExpressionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document[pushing: key] = value
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
            self.document[pushing: key] = value
        }
    }
    @inlinable public
    subscript(key:Granularity) -> Mongo.PreferredNumbers?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document[pushing: key] = value
        }
    }
    @inlinable public
    subscript(key:Mongo.BucketDocument.Output) -> Mongo.BucketOutputDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document[pushing: key] = value
        }
    }
}
