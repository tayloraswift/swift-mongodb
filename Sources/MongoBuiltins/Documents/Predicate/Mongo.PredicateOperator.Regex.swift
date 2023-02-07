extension Mongo.PredicateOperator
{
    @frozen public
    enum Regex:String, Hashable, Sendable
    {
        case regex = "$regex"
    }
}
