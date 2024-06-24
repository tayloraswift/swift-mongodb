import BSON

extension Mongo
{
    @frozen public
    struct BucketAutoDocument:Sendable
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
extension Mongo.BucketAutoDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.BucketAutoEncoder
}
