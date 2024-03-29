import BSON

extension Mongo
{
    @frozen public
    enum ValidationLevel:String, Hashable, Sendable
    {
        case moderate
        case strict
    }
}
extension Mongo.ValidationLevel:BSONDecodable, BSONEncodable
{
}
