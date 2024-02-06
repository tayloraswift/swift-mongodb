import BSON

@available(*, deprecated, renamed: "Mongo.Expression")
public
typealias MongoExpression = Mongo.Expression

extension Mongo
{
    @frozen public
    struct Expression:BSONRepresentable, BSONDecodable, BSONEncodable, Sendable
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
