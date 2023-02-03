extension MongoExpressionDSL.Map
{
    @frozen public
    enum For:String, Hashable, Sendable
    {
        case `for` = "as"
    }
}
