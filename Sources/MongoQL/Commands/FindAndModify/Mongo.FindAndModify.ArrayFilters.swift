extension Mongo.FindAndModify where Effect.Upsert == Bool
{
    @frozen public
    enum ArrayFilters:String, Hashable, Sendable
    {
        case arrayFilters
    }
}
