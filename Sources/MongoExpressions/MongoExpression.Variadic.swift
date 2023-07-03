extension MongoExpression
{
    @frozen public
    enum Variadic:String, Hashable, Sendable
    {
        case add                = "$add"
        case and                = "$and"
        case coalesce           = "$ifNull"
        case concatArrays       = "$concatArrays"
        case multiply           = "$multiply"
        case or                 = "$or"
        case zip                = "$zip"

        case setEquals          = "$setEquals"
        case setIntersection    = "$setIntersection"
        case setUnion           = "$setUnion"
    }
}
extension MongoExpression.Variadic
{
    @available(*, unavailable, renamed: "coalesce")
    public static
    var ifNull:Self
    {
        .coalesce
    }
}
