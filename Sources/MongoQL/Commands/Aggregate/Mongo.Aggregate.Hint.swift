extension Mongo.Aggregate
{
    @frozen public
    enum Hint:String, Hashable, Sendable
    {
        case hint
    }
}
