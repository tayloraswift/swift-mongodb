extension Mongo.Aggregate
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }
}
