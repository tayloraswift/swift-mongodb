extension Mongo.Find
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }
}
