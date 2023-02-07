extension Mongo.PipelineStage
{
    @frozen public
    enum Group:String, Hashable, Sendable
    {
        case group = "$group"
    }
}
