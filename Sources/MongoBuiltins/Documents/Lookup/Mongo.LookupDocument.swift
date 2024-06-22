import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct LookupDocument:Sendable
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
extension Mongo.LookupDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.LookupEncoder
}
