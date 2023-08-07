extension Mongo.Expression
{
    @frozen public
    enum Element:String, Hashable, Sendable
    {
        case element = "$arrayElemAt"
    }
}
extension Mongo.Expression.Element
{
    @available(*, unavailable, renamed: "element")
    public static
    var arrayElemAt:Self
    {
        .element
    }
}
