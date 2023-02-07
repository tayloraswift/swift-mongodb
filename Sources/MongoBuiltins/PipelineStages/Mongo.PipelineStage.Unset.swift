extension Mongo.PipelineStage
{
    @frozen public
    enum Unset:String, Hashable, Sendable
    {
        case unset = "$unset"
    }
}
