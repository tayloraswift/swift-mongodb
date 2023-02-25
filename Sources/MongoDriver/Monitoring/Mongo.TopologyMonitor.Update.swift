extension Mongo.TopologyMonitor
{
    struct Update
    {
        let topology:Mongo.TopologyUpdate
        let sessions:Mongo.LogicalSessions
        let owner:Mongo.MonitorTask?
    }
}
