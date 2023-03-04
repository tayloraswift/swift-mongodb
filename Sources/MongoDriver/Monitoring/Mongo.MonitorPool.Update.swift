extension Mongo.MonitorPool
{
    struct Update:Sendable
    {
        let topology:Mongo.TopologyUpdate
        let canary:Mongo.TopologyModel.Canary?

        init(topology:Mongo.TopologyUpdate,
            canary:Mongo.TopologyModel.Canary? = nil)
        {
            self.topology = topology
            self.canary = canary
        }
    }
}
