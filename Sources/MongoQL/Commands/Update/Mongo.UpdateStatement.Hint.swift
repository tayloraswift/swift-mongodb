extension Mongo.UpdateStatement
{
    @frozen public
    enum Hint:String, Hashable, Sendable
    {
        case hint
    }
}
