extension Mongo.PredicateOperator
{
    @frozen public
    enum Variadic:String, Hashable, Sendable
    {
        case all    = "$all"
        case `in`   = "$in"
        case nin    = "$nin"
    }
}
