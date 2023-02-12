extension Mongo.MergeDocument
{
    @frozen public
    enum WhenMatched:String, Hashable, Sendable
    {
        case whenMatched
    }
}
