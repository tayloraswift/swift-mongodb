extension MongoTopology
{
    @frozen public
    enum Member:Sendable
    {
        case primary(Replica)
        case secondary(Replica)
        case arbiter
        case other
    }
}
