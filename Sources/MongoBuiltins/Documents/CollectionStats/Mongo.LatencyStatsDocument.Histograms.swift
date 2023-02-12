extension Mongo.LatencyStatsDocument
{
    @frozen public
    enum Histograms:String, Hashable, Sendable
    {
        case histograms
    }
}
