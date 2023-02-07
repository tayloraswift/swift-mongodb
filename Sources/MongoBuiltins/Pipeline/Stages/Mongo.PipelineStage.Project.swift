extension Mongo.PipelineStage
{
    @frozen public
    enum Project:String, Hashable, Sendable
    {
        case project = "$project"
    }
}
