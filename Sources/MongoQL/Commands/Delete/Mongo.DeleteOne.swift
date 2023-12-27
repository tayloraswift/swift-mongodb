import BSON

extension Mongo
{
    @frozen public
    enum DeleteOne:Int32, Equatable, Hashable, Sendable
    {
        case one = 1
    }
}
extension Mongo.DeleteOne:BSONDecodable, BSONEncodable
{
}
