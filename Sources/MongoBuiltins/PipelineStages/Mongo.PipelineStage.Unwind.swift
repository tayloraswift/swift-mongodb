extension Mongo.PipelineStage
{
    @frozen public
    enum Unwind:String, Hashable, Sendable
    {
        case unwind = "$unwind"
    }
}
