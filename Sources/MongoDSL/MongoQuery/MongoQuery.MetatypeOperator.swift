extension MongoQuery
{
    @frozen public
    enum MetatypeOperator:String, Hashable, Sendable
    {
        case type = "$type"
    }
}
