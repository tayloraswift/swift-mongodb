import BSONDecoding
import BSONEncoding

extension Mongo.ReadPreference
{
    @frozen public
    enum Mode:String, Hashable, Sendable
    {
        case primary
        case primaryPreferred
        case secondaryPreferred
        case secondary
        case nearest
    }
}
extension Mongo.ReadPreference.Mode:BSONDecodable, BSONEncodable
{
}
