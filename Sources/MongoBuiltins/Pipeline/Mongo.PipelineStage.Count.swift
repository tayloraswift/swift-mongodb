extension Mongo.PipelineStage
{
    @frozen public
    enum Count:String, Hashable, Sendable
    {
        case count = "$count"
    }
}
