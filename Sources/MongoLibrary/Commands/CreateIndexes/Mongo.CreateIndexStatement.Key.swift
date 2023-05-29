extension Mongo.CreateIndexStatement
{
    @frozen public
    enum Key:String, Hashable, Sendable
    {
        case key
    }
}
