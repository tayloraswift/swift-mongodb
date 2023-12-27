extension Mongo.FindAndModify
{
    @frozen public
    enum Query:String, Hashable, Sendable
    {
        case query
    }
}
