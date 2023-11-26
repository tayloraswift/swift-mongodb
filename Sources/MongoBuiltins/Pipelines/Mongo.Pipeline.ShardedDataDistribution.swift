extension Mongo.Pipeline
{
    @frozen public
    enum ShardedDataDistribution:String, Hashable, Sendable
    {
        case shardedDataDistribution = "$shardedDataDistribution"
    }
}
