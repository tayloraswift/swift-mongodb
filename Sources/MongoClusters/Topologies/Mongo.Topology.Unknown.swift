extension Mongo.Topology
{
    public
    struct Unknown:Sendable
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
    init(from seedlist:Mongo.Seedlist)
    {
        self.init(ghosts: seedlist.dictionary(repeating: .queued))
    }
}
extension Mongo.Topology.Unknown
{
    mutating
    func combine(error status:(any Error)?, host:Mongo.Host) -> Mongo.TopologyUpdateResult
    {
        if case ()? = self.ghosts[host]?.clear(status: status)
        {
            .accepted
        }
        else
        {
            .rejected
        }
    }
    func topology<Metadata>(
        of _:Metadata.Type) -> [Mongo.Host: Mongo.ServerDescription<Metadata, Owner>]
    {
        self.ghosts.mapValues
        {
            switch $0
            {
            case .errored(let error):
                .errored(error)
            case .queued:
                .queued
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
            true
        }
        else
        {
            false
        }
    }
}
