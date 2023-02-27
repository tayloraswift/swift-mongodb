extension Mongo.TopologyMonitor
{
    struct Update:Sendable
    {
        let topology:Mongo.TopologyUpdate
        let sessions:Mongo.LogicalSessions
        let canary:Canary?
    }
}
