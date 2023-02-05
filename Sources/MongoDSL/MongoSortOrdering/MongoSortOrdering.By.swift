extension MongoSortOrdering
{
    @frozen public
    enum By:String, Hashable, Sendable
    {
        case by = "sortBy"
    }
}
extension MongoSortOrdering.By
{
    @available(*, unavailable, renamed: "by")
    public static
    var sortBy:Self
    {
        .by
    }
}
