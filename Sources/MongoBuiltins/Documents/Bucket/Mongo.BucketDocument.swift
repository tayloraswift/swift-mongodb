import BSON

extension Mongo
{
    @frozen public
    struct BucketDocument:Sendable
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
extension Mongo.BucketDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.BucketEncoder
}
