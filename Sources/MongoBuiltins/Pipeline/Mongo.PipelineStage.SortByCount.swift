extension Mongo.PipelineStage
{
    @frozen public
    enum SortByCount:String, Hashable, Sendable
    {
        case sortByCount = "$sortByCount"
    }
}
