extension Mongo.PipelineStage
{
    @frozen public
    enum Fill:String, Hashable, Sendable
    {
        case fill = "$fill"
    }
}
