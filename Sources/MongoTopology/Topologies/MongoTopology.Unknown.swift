import MongoChannel
import MongoConnection

extension MongoTopology
{
    public
    struct Unknown
    {
        private
        var ghosts:[Host: Unreachable]

        init(ghosts:[Host: Unreachable] = [:])
        {
            self.ghosts = ghosts
        }
    }
}
extension MongoTopology.Unknown
{
    /// Adds a *g* to every host in the given list of hosts.
    public
    init(hosts:Set<MongoTopology.Host>)
    {
        self.init(ghosts: .init(uniqueKeysWithValues: hosts.map { ($0, .queued) }))
    }
}
extension MongoTopology.Unknown
{
    var snapshot:[MongoTopology.Host: MongoTopology.Unreachable]
    {
        self.ghosts
    }
}
extension MongoTopology.Unknown
{
    mutating
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
    {
        self.ghosts[host]?.clear(status: status) ?? false
    }
    func topology<Metadata>(
        of _:Metadata.Type) -> [MongoTopology.Host: MongoConnection<Metadata>.State]
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
    func pick(host:MongoTopology.Host) -> Bool
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
