extension MongoTopology
{
    @frozen public
    enum Server:Sendable
    {
        case standalone(Standalone)
        case router(Router)

        case replica(Replica, Peerlist)
        case replicaGhost
    }
}
