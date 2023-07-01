import BSONEncoding
import BSONDecoding

extension Mongo
{
    @frozen public
    enum ExplainMode:String, Equatable, Hashable, Sendable
    {
        case queryPlanner
        case executionStats
        case allPlansExecution
    }
}
extension Mongo.ExplainMode:BSONDecodable, BSONEncodable
{
}
