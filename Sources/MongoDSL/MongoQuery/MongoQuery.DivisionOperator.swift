extension MongoQuery
{
    @frozen public
    enum DivisionOperator:String, Hashable, Sendable
    {
        case mod = "$mod"
    }
}
