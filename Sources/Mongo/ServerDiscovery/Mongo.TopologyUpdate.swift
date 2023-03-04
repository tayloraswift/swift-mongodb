extension Mongo
{
    @frozen public
    enum TopologyUpdate:Sendable
    {
        case primary(Primary, Peerlist)
        case slave(Slave, Peerlist)
        case ghost
        case router(Router)
        case standalone(Standalone)
    }
}
