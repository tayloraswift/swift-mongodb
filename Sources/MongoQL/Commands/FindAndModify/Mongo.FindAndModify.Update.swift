extension Mongo.FindAndModify where Effect.Upsert == Bool
{
    @frozen public
    enum Update:String, Hashable, Sendable
    {
        case update
    }
}
