import BSONDecoding
import BSONEncoding

extension Mongo.ProjectionOperator
{
    @frozen public
    enum Metadata:String, Hashable, Sendable
    {
        case textScore
        case indexKey
    }
}
extension Mongo.ProjectionOperator.Metadata:BSONDecodable, BSONEncodable
{
}
