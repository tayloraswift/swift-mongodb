extension Mongo.CollectionStatsDocument
{
    @frozen public
    enum LatencyStats:String, Hashable, Sendable
    {
        case latencyStats
    }
}
