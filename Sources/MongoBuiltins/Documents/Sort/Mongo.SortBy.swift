extension Mongo
{
    @frozen public
    enum SortBy:String, Hashable, Sendable
    {
        case by = "sortBy"
    }
}
extension Mongo.SortBy
{
    @available(*, unavailable, renamed: "by")
    public static
    var sortBy:Self
    {
        .by
    }
}
