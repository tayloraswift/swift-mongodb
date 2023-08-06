extension Mongo.PipelineStage
{
    @frozen public
    enum Out:String, Hashable, Sendable
    {
        case out = "$out"
    }
}
