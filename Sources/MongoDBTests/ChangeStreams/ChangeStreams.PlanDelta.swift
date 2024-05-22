import BSON
import MongoQL

extension ChangeStreams
{
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
}
extension ChangeStreams.PlanDelta:Mongo.MasterCodingDelta
{
    typealias Model = ChangeStreams.Plan
}
extension ChangeStreams.PlanDelta:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<ChangeStreams.Plan.CodingKey>) throws
    {
        self.init(
            owner: try bson[.owner]?.decode(),
            level: try bson[.level]?.decode())
    }
}
