import BSON

extension Mongo
{
    @frozen public
    struct ReduceDocument:Mongo.EncodableDocument, Sendable
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
extension Mongo.ReduceDocument
{
    @inlinable public
    subscript<Encodable>(key:Argument) -> Encodable?
        where Encodable:BSONEncodable
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
