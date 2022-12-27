extension Mongo
{
    @frozen public
    enum ReadLevel:Hashable, Sendable
    {
        case local
        case available
        case majority
        case linearizable
    }
}
