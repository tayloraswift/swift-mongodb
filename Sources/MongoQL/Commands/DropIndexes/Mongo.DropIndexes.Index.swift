extension Mongo.DropIndexes
{
    @frozen public
    enum Index:String, Hashable, Sendable
    {
        case index
    }
}
