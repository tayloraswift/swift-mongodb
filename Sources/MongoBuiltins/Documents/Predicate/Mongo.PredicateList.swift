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
extension Mongo.PredicateList
{
    @inlinable public
    init(with populate:(inout Mongo.PredicateListEncoder) throws -> ()) rethrows
    {
        self.init(.init())
        try populate(&self.bson.output[as: Mongo.PredicateListEncoder.self])
    }
}
