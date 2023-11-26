extension Mongo.Pipeline
{
    @frozen public
    enum IndexStats:String, Hashable, Sendable
    {
        case indexStats = "$indexStats"
    }
}
