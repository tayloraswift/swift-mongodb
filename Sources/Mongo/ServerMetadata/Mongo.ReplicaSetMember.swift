extension Mongo
{
    @frozen public
    enum ReplicaSetMember:Sendable
    {
        case primary(Replica)
        case secondary(Replica)
        case arbiter
        case other
    }
}
