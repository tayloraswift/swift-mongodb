import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    enum ValidationAction:String, Hashable, Sendable
    {
        case error
        case warn
    }
}
extension Mongo.ValidationAction:BSONDecodable, BSONEncodable
{
}
