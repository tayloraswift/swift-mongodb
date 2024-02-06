import BSON
import MongoABI

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
    subscript(path:Mongo.AnyKeyPath) -> Mongo.Accumulator?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path.stem])
        }
    }
}
