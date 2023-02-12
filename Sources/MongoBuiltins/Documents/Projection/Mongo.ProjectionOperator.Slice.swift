extension Mongo.ProjectionOperator
{
    @frozen public
    enum Slice:String, Hashable, Sendable
    {
        case slice = "$slice"
    }
}
