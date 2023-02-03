extension MongoExpressionDSL.Filter
{
    @frozen public
    enum Argument:String, Hashable, Sendable
    {
        case input
        case `where` = "cond"
        case limit
    }
}
