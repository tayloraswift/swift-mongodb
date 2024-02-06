import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct FacetDocument:Mongo.EncodableDocument, Sendable
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
extension Mongo.FacetDocument
{
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Mongo.Pipeline?
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
