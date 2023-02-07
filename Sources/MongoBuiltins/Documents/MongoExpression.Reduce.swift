extension MongoExpression
{
    @frozen public
    enum Reduce:String, Hashable, Sendable
    {
        case reduce = "$reduce"
    }
}
