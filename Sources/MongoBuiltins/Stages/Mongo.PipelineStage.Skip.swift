extension Mongo.PipelineStage
{
    @frozen public
    enum Skip:String, Hashable, Sendable
    {
        case skip = "$skip"
    }
}
