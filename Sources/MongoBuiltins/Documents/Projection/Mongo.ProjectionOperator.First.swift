extension Mongo.ProjectionOperator
{
    @frozen public
    enum First:String, Hashable, Sendable
    {
        case first = "$elemMatch"
    }
}
extension Mongo.ProjectionOperator.First
{
    @available(*, unavailable, renamed: "first")
    public static
    var elemMatch:Self
    {
        .first
    }
}
