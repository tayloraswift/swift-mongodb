extension Mongo.UnwindDocument
{
    @frozen public
    enum ArrayIndexAs:String, Hashable, Sendable
    {
        case arrayIndexAs = "includeArrayIndex"
    }
}
extension Mongo.UnwindDocument.ArrayIndexAs
{
    @available(*, unavailable, renamed: "arrayIndexAs")
    public static
    var includeArrayIndex:Self
    {
        .arrayIndexAs
    }
}
