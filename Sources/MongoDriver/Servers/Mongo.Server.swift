extension Mongo
{
    enum Server:Sendable
    {
        case single(Single)
        case router(Router)

        case replica(Replica, Peerlist)
        case replicaGhost
    }
}
