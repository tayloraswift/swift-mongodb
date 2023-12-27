extension Mongo.UpdateStatement
{
    @frozen public
    enum Upsert:String, Hashable, Sendable
    {
        case upsert
    }
}
