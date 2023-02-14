extension Mongo.ListDatabases
{
    @frozen public
    enum AuthorizedDatabases:String, Hashable, Sendable
    {
        case authorizedDatabases
    }
}
