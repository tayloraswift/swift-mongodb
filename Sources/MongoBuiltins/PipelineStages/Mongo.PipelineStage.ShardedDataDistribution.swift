extension Mongo.PipelineStage
{
    @frozen public
    enum ShardedDataDistribution:String, Hashable, Sendable
    {
        case shardedDataDistribution = "$shardedDataDistribution"
    }
}
