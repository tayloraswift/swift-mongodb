extension MongoExpressionDSL.Operator
{
    @frozen public
    enum Element:String, Hashable, Sendable
    {
        case element = "$arrayElemAt"
    }
}
extension MongoExpressionDSL.Operator.Element
{
    @available(*, unavailable, renamed: "element")
    public static
    var arrayElemAt:Self
    {
        .element
    }
}
