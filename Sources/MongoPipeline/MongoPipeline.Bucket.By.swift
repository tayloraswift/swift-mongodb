extension MongoPipeline.Bucket
{
    @frozen public
    enum By:String, Hashable, Sendable
    {
        case by = "groupBy"
    }
}
extension MongoPipeline.Bucket.By
{
    @available(*, unavailable, renamed: "by")
    public static
    var groupBy:Self
    {
        .by
    }
}
