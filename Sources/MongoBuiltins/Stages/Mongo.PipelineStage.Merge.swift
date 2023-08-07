extension Mongo.PipelineStage
{
    @frozen public
    enum Merge:String, Hashable, Sendable
    {
        case merge = "$merge"
    }
}
