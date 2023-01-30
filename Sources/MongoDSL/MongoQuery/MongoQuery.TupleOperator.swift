extension MongoQuery
{
    @frozen public
    enum TupleOperator:String, Hashable, Sendable
    {
        case all    = "$all"
        case `in`   = "$in"
        case nin    = "$nin"
    }
}
