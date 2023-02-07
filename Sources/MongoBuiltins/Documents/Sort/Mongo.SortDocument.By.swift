extension Mongo.SortDocument
{
    @frozen public
    enum By:String, Hashable, Sendable
    {
        case by = "sortBy"
    }
}
extension Mongo.SortDocument.By
{
    @available(*, unavailable, renamed: "by")
    public static
    var sortBy:Self
    {
        .by
    }
}
