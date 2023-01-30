extension MongoQuery
{
    @frozen public
    enum Operator:String, Hashable, Sendable
    {
        case not = "$not"
        case any = "$elemMatch"
    }
}
extension MongoQuery.Operator
{
    @available(*, unavailable, renamed: "any")
    public static
    var elemMatch:Self
    {
        .any
    }
}
