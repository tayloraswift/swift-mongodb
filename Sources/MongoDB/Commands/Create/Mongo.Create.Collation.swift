extension Mongo.Create
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }
}
