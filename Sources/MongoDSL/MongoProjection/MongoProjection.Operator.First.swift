extension MongoProjection.Operator
{
    @frozen public
    enum First:String, Hashable, Sendable
    {
        case first = "$elemMatch"
    }
}
extension MongoProjection.Operator.First
{
    @available(*, unavailable, renamed: "first")
    public static
    var elemMatch:Self
    {
        .first
    }
}
