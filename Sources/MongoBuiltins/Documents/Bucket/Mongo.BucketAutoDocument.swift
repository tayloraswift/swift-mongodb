import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct BucketAutoDocument:BSONRepresentable, BSONDSL, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
        }
    }
}
