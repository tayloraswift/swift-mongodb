extension Mongo.MonitorPool
{
    struct Update:Sendable
    {
        let topology:Mongo.TopologyUpdate
        let sessions:Mongo.LogicalSessions

        let canary:Mongo.TopologyModel.Canary?

        init(topology:Mongo.TopologyUpdate,
            sessions:Mongo.LogicalSessions,
            canary:Mongo.TopologyModel.Canary? = nil)
        {
            self.topology = topology
            self.sessions = sessions

            self.canary = canary
        }
    }
}
