extension Mongo.PipelineStage
{
    @frozen public
    enum Lookup:String, Hashable, Sendable
    {
        case lookup = "$lookup"
    }
}
