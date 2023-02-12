extension Mongo.PredicateOperator
{
    @frozen public
    enum Exists:String, Hashable, Sendable
    {
        case exists = "$exists"
    }
}
