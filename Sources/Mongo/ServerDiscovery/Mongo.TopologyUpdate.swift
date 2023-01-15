extension Mongo
{
    @frozen public
    enum TopologyUpdate:Sendable
    {
        case standalone(Standalone)
        case router(Router)
        case master(Master, Peerlist)
        case slave(Slave, Peerlist)
    }
}
