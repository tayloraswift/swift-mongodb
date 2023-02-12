extension Mongo.PipelineStage
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort = "$sort"
    }
}
