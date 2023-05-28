extension Mongo.UpdateStatement
{
    @frozen public
    enum ArrayFilters:String, Hashable, Sendable
    {
        case arrayFilters
    }
}
