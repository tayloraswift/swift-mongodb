import BSON

extension Mongo
{
    @frozen public
    struct PredicateOperator:Sendable
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
extension Mongo.PredicateOperator:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.PredicateOperatorEncoder
}
