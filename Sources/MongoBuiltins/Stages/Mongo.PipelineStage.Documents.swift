extension Mongo.PipelineStage
{
    @frozen public
    enum Documents:String, Hashable, Sendable
    {
        case documents = "$documents"
    }
}
