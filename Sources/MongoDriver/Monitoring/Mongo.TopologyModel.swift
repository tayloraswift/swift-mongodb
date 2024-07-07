import UnixTime

extension Mongo
{
    struct TopologyModel
    {
        /// The monitoring interval, in milliseconds.
        let interval:Milliseconds

        private
        var topology:Topology<Canary>

        init(interval:Milliseconds, topology:Topology<Canary>)
        {
            self.interval = interval
            self.topology = topology
        }
    }
}
extension Mongo.TopologyModel
{
    mutating
    func combine(update:consuming Mongo.TopologyUpdate,
        owner:consuming Canary?,
        host:Mongo.Host,
        add:(Mongo.Host) -> ()) ->
    (
        result:Mongo.TopologyUpdateResult,
        table:Mongo.ServerTable
    )
    {
        let result:Mongo.TopologyUpdateResult = self.topology.combine(update: update,
            owner: owner,
            host: host,
            add: add)

        let table:Mongo.ServerTable = .init(from: self.topology,
            heartbeatInterval: self.interval)

        return (result, table)
    }
    mutating
    func combine(error:consuming (any Error)?,
        host:Mongo.Host) ->
    (
        result:Mongo.TopologyUpdateResult,
        table:Mongo.ServerTable
    )
    {
        let result:Mongo.TopologyUpdateResult = self.topology.combine(error: error,
            host: host)
        let table:Mongo.ServerTable = .init(from: self.topology,
            heartbeatInterval: self.interval)

        return (result, table)
    }
}
