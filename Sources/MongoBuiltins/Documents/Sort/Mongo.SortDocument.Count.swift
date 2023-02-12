extension Mongo.SortDocument
{
    @frozen public
    enum Count:String, Hashable, Sendable
    {
        case count = "n"
    }
}
extension Mongo.SortDocument.Count
{
    @available(*, unavailable, renamed: "count")
    public static
    var n:Self
    {
        .count
    }
}
