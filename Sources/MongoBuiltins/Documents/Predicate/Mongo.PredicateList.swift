import BSON

extension Mongo
{
    @frozen public
    struct PredicateList:BSONRepresentable, BSONDecodable, BSONEncodable, Sendable
    {
        public
        var bson:BSON.List

        @inlinable public
        init(_ bson:BSON.List)
        {
            self.bson = bson
        }
    }
}
extension Mongo.PredicateList:Mongo.EncodableList
{
    public
    typealias Encoder = Mongo.PredicateListEncoder
}
