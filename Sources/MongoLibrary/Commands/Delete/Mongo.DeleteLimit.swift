import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    enum DeleteLimit:Int32, Equatable, Hashable, Sendable
    {
        case unlimited = 0
        case one = 1
    }
}
extension Mongo.DeleteLimit:BSONDecodable, BSONEncodable
{
}
