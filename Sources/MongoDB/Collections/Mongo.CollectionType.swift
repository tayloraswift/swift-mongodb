import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    enum CollectionType:String, Hashable, Sendable
    {
        case collection
        case timeseries
        case view
    }
}
extension Mongo.CollectionType:BSONDecodable, BSONEncodable
{
}
