extension Mongo.UnwindDocument
{
    @frozen public
    enum Field:String, Hashable, Sendable
    {
        case arrayIndexAs = "includeArrayIndex"
        case path
    }
}
extension Mongo.UnwindDocument.Field
{
    @available(*, unavailable, renamed: "arrayIndexAs")
    public static
    var includeArrayIndex:Self
    {
        .arrayIndexAs
    }
}
