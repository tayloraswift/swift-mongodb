extension MongoQuery.Document
{
    @frozen public
    enum LogicalOperator:String, Hashable, Sendable
    {
        case and    = "$and"
        case nor    = "$nor"
        case or     = "$or"
    }
}
