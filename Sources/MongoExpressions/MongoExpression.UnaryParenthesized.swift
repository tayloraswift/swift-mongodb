extension MongoExpression
{
    @frozen public
    enum UnaryParenthesized:String, Hashable, Sendable
    {
        case isArray            = "$isArray"
        case not                = "$not"
        case type               = "$type"

        case allElementsTrue    = "$allElementsTrue"
        case anyElementTrue     = "$anyElementTrue"
    }
}
