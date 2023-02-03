extension MongoExpressionDSL.Operator
{
    @frozen public
    enum UnaryParenthesized:String, Hashable, Sendable
    {
        case not        = "$not"
        case isArray    = "$isArray"
    }
}
