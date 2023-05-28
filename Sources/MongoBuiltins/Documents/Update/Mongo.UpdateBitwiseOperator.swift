import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    enum UpdateBitwiseOperator:String, Equatable, Hashable, Sendable
    {
        case and
        case or
        case xor
    }
}
extension Mongo.UpdateBitwiseOperator:BSONDecodable, BSONEncodable
{
}
