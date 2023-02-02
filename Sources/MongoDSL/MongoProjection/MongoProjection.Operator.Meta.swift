extension MongoProjection.Operator
{
    @frozen public
    enum Meta:String, Hashable, Sendable
    {
        case meta = "$meta"
    }
}
