extension Mongo.MergeDocument
{
    @frozen public
    enum WhenNotMatched:String, Hashable, Sendable
    {
        case whenNotMatched
    }
}
