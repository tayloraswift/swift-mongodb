extension MongoExpressionDSL.Operator
{
    @frozen public
    enum In:String, Hashable, Sendable
    {
        case `in` = "$in"
    }
}
