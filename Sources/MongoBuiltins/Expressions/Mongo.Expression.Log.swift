extension Mongo.Expression
{
    @frozen public
    enum Log:String, Hashable, Sendable
    {
        case log = "$log"
    }
}
