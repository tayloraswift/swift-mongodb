extension MongoPredicate.Operator
{
    @frozen public
    enum Recursive:String, Hashable, Sendable
    {
        case not = "$not"
        case any = "$elemMatch"
    }
}
extension MongoPredicate.Operator.Recursive
{
    @available(*, unavailable, renamed: "any")
    public static
    var elemMatch:Self
    {
        .any
    }
}
