extension MongoExpression
{
    @frozen public
    enum Element:String, Hashable, Sendable
    {
        case element = "$arrayElemAt"
    }
}
extension MongoExpression.Element
{
    @available(*, unavailable, renamed: "element")
    public static
    var arrayElemAt:Self
    {
        .element
    }
}
