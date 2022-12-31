extension MongoTopology
{
    @frozen public
    enum Undesirable:Hashable, Sendable
    {
        case standalone
        case primary
        case secondary
        case arbiter
        case other
        case ghost
    }
}
