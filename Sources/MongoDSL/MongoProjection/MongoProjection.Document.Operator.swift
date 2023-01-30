extension MongoProjection.Document
{
    @frozen public
    enum Operator:String, Hashable, Sendable
    {
        case any = "$elemMatch"
    }
}
extension MongoProjection.Document.Operator
{
    @available(*, unavailable, renamed: "any")
    public static
    var elemMatch:Self
    {
        .any
    }
}
