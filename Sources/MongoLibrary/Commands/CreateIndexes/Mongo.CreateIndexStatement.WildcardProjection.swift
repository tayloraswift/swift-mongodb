extension Mongo.CreateIndexStatement
{
    @frozen public
    enum WildcardProjection:String, Hashable, Sendable
    {
        case wildcardProjection
    }
}
