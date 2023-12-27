extension Mongo.ListCollections
{
    @frozen public
    enum AuthorizedCollections:String, Hashable, Sendable
    {
        case authorizedCollections
    }
}
