extension Mongo.Pipeline
{
    @frozen public
    enum SortByCount:String, Hashable, Sendable
    {
        case sortByCount = "$sortByCount"
    }
}
