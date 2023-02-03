import BSONDecoding
import BSONEncoding

extension MongoSortOrdering
{
    @frozen public
    enum Metadata:String, Hashable, Sendable
    {
        case textScore
    }
}
extension MongoSortOrdering.Metadata:BSONDecodable, BSONEncodable
{
}
