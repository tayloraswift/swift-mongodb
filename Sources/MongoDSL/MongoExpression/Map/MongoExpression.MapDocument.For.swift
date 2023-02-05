extension MongoExpression.MapDocument
{
    @frozen public
    enum For:String, Hashable, Sendable
    {
        case `for` = "as"
    }
}
