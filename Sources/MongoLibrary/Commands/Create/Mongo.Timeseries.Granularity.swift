import BSONDecoding
import BSONEncoding

extension Mongo.Timeseries
{
    @frozen public
    enum Granularity:String, Hashable, Sendable
    {
        case seconds
        case minutes
        case hours
    }
}
extension Mongo.Timeseries.Granularity:BSONDecodable, BSONEncodable
{
}
