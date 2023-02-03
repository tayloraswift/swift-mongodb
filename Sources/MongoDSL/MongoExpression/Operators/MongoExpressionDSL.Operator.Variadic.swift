extension MongoExpressionDSL.Operator
{
    @frozen public
    enum Variadic:String, Hashable, Sendable
    {
        case add            = "$add"
        case and            = "$and"
        case coalesce       = "$ifNull"
        case concatArrays   = "$concatArrays"
        case multiply       = "$multiply"
        case or             = "$or"
        case zip            = "$zip"
    }
}
extension MongoExpressionDSL.Operator.Variadic
{
    @available(*, unavailable, renamed: "coalesce")
    public static
    var ifNull:Self
    {
        .coalesce
    }
}
