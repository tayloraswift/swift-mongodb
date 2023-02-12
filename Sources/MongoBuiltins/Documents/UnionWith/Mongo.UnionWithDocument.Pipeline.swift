extension Mongo.UnionWithDocument
{
    @frozen public
    enum Pipeline:String, Hashable, Sendable
    {
        case pipeline
    }
}
