extension Mongo.PipelineStage
{
    @frozen public
    enum Limit:String, Hashable, Sendable
    {
        case limit = "$limit"
    }
}
