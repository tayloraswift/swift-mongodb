extension Mongo.ListDatabases
{
    @frozen public
    enum Filter:String, Hashable, Sendable
    {
        case filter
    }
}
