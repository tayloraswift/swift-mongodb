extension Mongo.BucketDocument
{
    @frozen public
    enum By:String, Hashable, Sendable
    {
        case by = "groupBy"
    }
}
extension Mongo.BucketDocument.By
{
    @available(*, unavailable, renamed: "by")
    public static
    var groupBy:Self
    {
        .by
    }
}
