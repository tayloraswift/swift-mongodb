extension Mongo.Pipeline
{
    @frozen public
    enum PlanCacheStats:String, Hashable, Sendable
    {
        case planCacheStats = "$planCacheStats"
    }
}
