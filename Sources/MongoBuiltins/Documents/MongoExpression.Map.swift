import MongoExpressions

extension MongoExpression
{
    @frozen public
    enum Map:String, Hashable, Sendable
    {
        case map = "$map"
    }
}
