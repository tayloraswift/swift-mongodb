extension MongoQuery
{
    @frozen public
    enum BooleanOperator:String, Hashable, Sendable
    {
        case exists = "$exists"
    }
}
