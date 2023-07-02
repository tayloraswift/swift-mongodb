extension MongoExpression
{
    @frozen public
    enum Log:String, Hashable, Sendable
    {
        case log = "$log"
    }
}
