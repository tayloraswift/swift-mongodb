extension MongoProjection.Document
{
    @frozen public
    enum RangeOperator:String, Hashable, Sendable
    {
        case slice = "$slice"
    }
}
