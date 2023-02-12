extension Mongo.PredicateOperator
{
    @frozen public
    enum Recursive:String, Hashable, Sendable
    {
        case not = "$not"
        case any = "$elemMatch"
    }
}
extension Mongo.PredicateOperator.Recursive
{
    @available(*, unavailable, renamed: "any")
    public static
    var elemMatch:Self
    {
        .any
    }
}
