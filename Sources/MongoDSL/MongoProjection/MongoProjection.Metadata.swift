import BSONDecoding
import BSONEncoding

extension MongoProjection
{
    @frozen public
    enum Metadata:String, Hashable, Sendable
    {
        case textScore
        case indexKey
    }
}
extension MongoProjection.Metadata:BSONDecodable, BSONEncodable
{
}
