extension Mongo.PipelineStage
{
    @frozen public
    enum Match:String, Hashable, Sendable
    {
        case match = "$match"
    }
}
