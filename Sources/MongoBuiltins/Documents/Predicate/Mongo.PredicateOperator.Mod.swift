extension Mongo.PredicateOperator
{
    @frozen public
    enum Mod:String, Hashable, Sendable
    {
        case mod = "$mod"
    }
}
