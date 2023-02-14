extension Mongo.ListCollections
{
    @frozen public
    enum Filter:String, Hashable, Sendable
    {
        case filter
    }
}
