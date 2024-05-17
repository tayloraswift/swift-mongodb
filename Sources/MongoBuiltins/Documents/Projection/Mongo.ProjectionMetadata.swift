import BSON

extension Mongo
{
    @frozen public
    enum ProjectionMetadata:String, Hashable, Sendable
    {
        case textScore
        case indexKey
    }
}
extension Mongo.ProjectionMetadata:BSONDecodable, BSONEncodable
{
}
