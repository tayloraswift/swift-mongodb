extension MongoSortOrdering
{
    @frozen public
    enum Count:String, Hashable, Sendable
    {
        case count = "n"
    }
}
extension MongoSortOrdering.Count
{
    @available(*, unavailable, renamed: "count")
    public static
    var n:Self
    {
        .count
    }
}
