extension Mongo.Pipeline
{
    @frozen public
    enum UnionWith:String, Hashable, Sendable
    {
        case unionWith = "$unionWith"
    }
}
