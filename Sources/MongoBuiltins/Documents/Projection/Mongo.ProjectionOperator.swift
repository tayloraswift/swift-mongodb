import BSON

extension Mongo
{
    @frozen public
    struct ProjectionOperator:Sendable
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
extension Mongo.ProjectionOperator:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.ProjectionOperatorEncoder
}
