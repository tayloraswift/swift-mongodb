import BSONDecoding
import BSONEncoding

extension Mongo.Collation
{
    @frozen public 
    enum CaseFirst:String, Sendable 
    {
        case lower
        case upper
    }
}
extension Mongo.Collation.CaseFirst:BSONDecodable, BSONEncodable
{
}
