import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct LetDocument:Sendable
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
extension Mongo.LetDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.LetEncoder
}
