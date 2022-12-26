import MongoChannel

extension MongoTopology
{
    public
    struct Unknown
    {
        private
        var seeds:[Host: MongoChannel.State<Never>]

        init(seeds:[Host: MongoChannel.State<Never>] = [:])
        {
            self.seeds = seeds
        }
    }
}
extension MongoTopology.Unknown
{
    public
    init(hosts:Set<MongoTopology.Host>)
    {
        self.init(seeds: .init(uniqueKeysWithValues: hosts.map { ($0, .queued) }))
    }
}
extension MongoTopology.Unknown
{
    func errors() -> [MongoTopology.Host: any Error]
    {
        self.seeds.compactMapValues(\.error)
    }
}
extension MongoTopology.Unknown
{
    mutating
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
    {
        self.seeds[host]?.clear(status: status) ?? false
    }
    func topology<Metadata>(
        of _:Metadata.Type) -> [MongoTopology.Host: MongoChannel.State<Metadata>]
    {
        self.seeds.mapValues
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
    /// Removes the given host from the seedlist if present, returning [`true`]()
    /// if it was the only seed in the seedlist. Returns [`false`]() otherwise.
    @discardableResult
    mutating
    func pick(host:MongoTopology.Host) -> Bool
    {
        if case _? = self.seeds.removeValue(forKey: host), self.seeds.isEmpty
        {
            return true
        }
        else
        {
            return false
        }
    }
}
