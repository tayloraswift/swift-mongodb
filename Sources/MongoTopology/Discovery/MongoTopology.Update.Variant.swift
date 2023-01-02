extension MongoTopology.Update
{
    @frozen public
    enum Variant:Sendable
    {
        case standalone(MongoTopology.Standalone)
        case router(MongoTopology.Router)
        case master(MongoTopology.Master, MongoTopology.Peerlist)
        case slave(MongoTopology.Slave, MongoTopology.Peerlist)
    }
}
