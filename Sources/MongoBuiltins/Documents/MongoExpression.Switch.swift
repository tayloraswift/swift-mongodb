import MongoExpressions

extension MongoExpression
{
    @frozen public
    enum Switch:String, Hashable, Sendable
    {
        case `switch` = "$switch"
    }
}
