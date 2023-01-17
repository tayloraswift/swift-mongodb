import MongoMonitoring

extension Mongo.Topology
{
    public
    struct Unknown
    {
        public private(set)
        var ghosts:[Mongo.Host: Mongo.Unreachable]

        init(ghosts:[Mongo.Host: Mongo.Unreachable] = [:])
        {
            self.ghosts = ghosts
        }
    }
}
extension Mongo.Topology.Unknown
{
    /// Adds a *g* to every host in the given list of hosts.
    public
    init(hosts:Set<Mongo.Host>)
    {
        self.init(ghosts: .init(uniqueKeysWithValues: hosts.map { ($0, .queued) }))
    }
}
extension Mongo.Topology.Unknown
{
    mutating
    func combine(error status:(any Error)?, host:Mongo.Host) -> Bool
    {
        self.ghosts[host]?.clear(status: status) ?? false
    }
    func topology<Metadata>(
        of _:Metadata.Type) -> [Mongo.Host: Mongo.ServerDescription<Metadata, Pool>]
    {
        self.ghosts.mapValues
        {
            switch $0
            {
            case .errored(let error):
                return .errored(error)
            case .queued:
                return .queued
            }
        }
    }
    /// Removes the given host from the topology if present, returning [`true`]()
    /// if it was the only ghost in the topology. Returns [`false`]() otherwise.
    @discardableResult
    mutating
    func pick(host:Mongo.Host) -> Bool
    {
        if case _? = self.ghosts.removeValue(forKey: host), self.ghosts.isEmpty
        {
            return true
        }
        else
        {
            return false
        }
    }
}
