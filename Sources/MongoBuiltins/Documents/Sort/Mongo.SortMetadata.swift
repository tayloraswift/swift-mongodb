import BSON

extension Mongo
{
    @frozen public
    enum SortMetadata:String, Hashable, Sendable
    {
        case textScore
    }
}
extension Mongo.SortMetadata:BSONDecodable, BSONEncodable
{
}
