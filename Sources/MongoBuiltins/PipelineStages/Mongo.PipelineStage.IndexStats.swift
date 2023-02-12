extension Mongo.PipelineStage
{
    @frozen public
    enum IndexStats:String, Hashable, Sendable
    {
        case indexStats = "$indexStats"
    }
}
