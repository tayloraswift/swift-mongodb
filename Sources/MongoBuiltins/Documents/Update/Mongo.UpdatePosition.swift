import BSON

extension Mongo
{
    @frozen public
    enum UpdatePosition:Int32, Equatable, Hashable, Sendable
    {
        case first = -1
        case last = 1
    }
}
extension Mongo.UpdatePosition:BSONDecodable, BSONEncodable
{
}
