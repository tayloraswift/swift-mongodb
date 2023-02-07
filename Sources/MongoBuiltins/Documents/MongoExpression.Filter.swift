extension MongoExpression
{
    @frozen public
    enum Filter:String, Hashable, Sendable
    {
        case filter = "$filter"
    }
}
