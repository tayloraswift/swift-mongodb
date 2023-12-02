import BSON
import MongoSchema

extension Mongo
{
    @frozen public
    struct FacetDocument:MongoDocumentDSL, Sendable
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
    subscript(path:Mongo.KeyPath) -> Mongo.Pipeline?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
}
