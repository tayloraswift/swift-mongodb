import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct BucketOutputDocument:BSONRepresentable, BSONDSL, Sendable
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
            self.bson.push(key, value)
        }
    }
}
