import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct SortDocument:Sendable
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
extension Mongo.SortDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.SortEncoder
}
