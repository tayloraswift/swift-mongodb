extension Mongo.UpdateStatement
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }
}
