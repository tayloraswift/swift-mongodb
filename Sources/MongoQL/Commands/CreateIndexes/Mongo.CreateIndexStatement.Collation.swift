extension Mongo.CreateIndexStatement
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }
}
