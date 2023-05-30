extension Mongo.Delete
{
    @frozen public
    enum Ordered:String, Equatable, Hashable, Sendable
    {
        case ordered
    }
}
