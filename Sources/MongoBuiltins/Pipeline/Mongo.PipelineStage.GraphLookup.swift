extension Mongo.PipelineStage
{
    @frozen public
    enum GraphLookup:String, Hashable, Sendable
    {
        case graphLookup = "$graphLookup"
    }
}
