import BSON
import MongoQL

struct PlanDelta:Equatable, Sendable
{
    var owner:String?
    var level:String?

    init(owner:String? = nil, level:String? = nil)
    {
        self.owner = owner
        self.level = level
    }
}
extension PlanDelta:Mongo.MasterCodingDelta
{
    typealias Model = Plan
}
extension PlanDelta:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<Plan.CodingKey>) throws
    {
        self.init(
            owner: try bson[.owner]?.decode(),
            level: try bson[.level]?.decode())
    }
}
