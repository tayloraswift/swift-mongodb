extension Mongo.PipelineStage
{
    @frozen public
    enum PlanCacheStats:String, Hashable, Sendable
    {
        case planCacheStats = "$planCacheStats"
    }
}
