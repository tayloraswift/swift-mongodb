import BSON

extension Mongo.SortOperator
{
    @frozen public
    enum Metadata:String, Hashable, Sendable
    {
        case textScore
    }
}
extension Mongo.SortOperator.Metadata:BSONDecodable, BSONEncodable
{
}
