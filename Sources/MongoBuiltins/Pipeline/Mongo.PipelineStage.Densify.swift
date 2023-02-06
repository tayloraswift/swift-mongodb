extension Mongo.PipelineStage
{
    @frozen public
    enum Densify:String, Hashable, Sendable
    {
        case densify = "$densify"
    }
}
