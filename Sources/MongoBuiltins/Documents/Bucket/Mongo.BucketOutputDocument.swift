import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct BucketOutputDocument:Sendable
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
extension Mongo.BucketOutputDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.BucketOutputEncoder
}
