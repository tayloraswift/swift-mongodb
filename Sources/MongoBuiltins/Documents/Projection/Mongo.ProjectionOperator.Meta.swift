extension Mongo.ProjectionOperator
{
    @frozen public
    enum Meta:String, Hashable, Sendable
    {
        case meta = "$meta"
    }
}
