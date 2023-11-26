extension Mongo.Pipeline
{
    @frozen public
    enum Sort:String, Hashable, Sendable
    {
        case sort = "$sort"
    }
}
