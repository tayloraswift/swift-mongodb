extension Mongo.CreateIndexStatement
{
    @frozen public
    enum Flag:String, Hashable, Sendable
    {
        case unique
        case sparse
        case hidden
    }
}
