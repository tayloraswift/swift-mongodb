extension MongoExpressionDSL.Filter
{
    @frozen public
    enum For:String, Hashable, Sendable
    {
        case `for` = "as"
    }
}
