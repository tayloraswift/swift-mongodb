import BSON

extension Mongo
{
    @frozen public
    struct SortOperator:MongoDocumentDSL, Sendable
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
extension Mongo.SortOperator
{
    @inlinable public
    subscript(key:Meta) -> Metadata?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
