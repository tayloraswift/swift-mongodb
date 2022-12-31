extension MongoTopology
{
    @frozen public
    enum Update:Sendable
    {
        case standalone(Standalone)
        case router(Router)
        case master(Master, Peerlist)
        case slave(Slave, Peerlist)
    }
}
