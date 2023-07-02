import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct BucketOutputDocument:MongoDocumentDSL, Sendable
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
extension Mongo.BucketOutputDocument
{
    @inlinable public
    subscript(key:BSON.Key) -> Mongo.Accumulator?
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
