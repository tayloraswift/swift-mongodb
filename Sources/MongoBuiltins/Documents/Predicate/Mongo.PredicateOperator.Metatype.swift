extension Mongo.PredicateOperator
{
    @frozen public
    enum Metatype:String, Hashable, Sendable
    {
        case type = "$type"
    }
}
