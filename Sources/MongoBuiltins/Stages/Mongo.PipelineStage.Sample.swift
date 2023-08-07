extension Mongo.PipelineStage
{
    @frozen public
    enum Sample:String, Hashable, Sendable
    {
        case sample = "$sample"
    }
}
