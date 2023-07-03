import BSONEncoding

extension Mongo
{
    @frozen public
    struct BucketDocument:MongoDocumentDSL, Sendable
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
extension Mongo.BucketDocument
{
    @inlinable public
    subscript<Encodable>(key:Argument) -> Encodable? where Encodable:BSONEncodable
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
    subscript<Encodable>(key:By) -> Encodable? where Encodable:BSONEncodable
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
    subscript(key:Output) -> Mongo.BucketOutputDocument?
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
