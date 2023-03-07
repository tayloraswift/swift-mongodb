extension Mongo.Find
{
    @frozen public
    enum Hint:String, Hashable, Sendable
    {
        case hint
    }
}
