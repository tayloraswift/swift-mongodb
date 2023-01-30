extension MongoQuery
{
    @frozen public
    enum RegexOperator:String, Hashable, Sendable
    {
        case regex = "$regex"
    }
}
