extension Mongo.PipelineStage
{
    @frozen public
    enum UnionWith:String, Hashable, Sendable
    {
        case unionWith = "$unionWith"
    }
}
