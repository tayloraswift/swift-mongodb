extension Mongo
{
    public
    struct Seedlist
    {
        private
        var seeds:[Mongo.Host: Mongo.ConnectionState<Never>]

        init(seeds:[Mongo.Host: Mongo.ConnectionState<Never>] = [:])
        {
            self.seeds = seeds
        }
    }
}
extension Mongo.Seedlist
{
    public
    init(hosts:Set<Mongo.Host>)
    {
        self.init(seeds: .init(uniqueKeysWithValues: hosts.map { ($0, .queued) }))
    }
}
extension Mongo.Seedlist
{
    mutating
    func clear(host:Mongo.Host, status:(any Error)?) -> Void?
    {
        self.seeds[host]?.clear(status: status)
    }
    func topology<Metadata>(of _:Metadata.Type) -> [Mongo.Host: Mongo.ConnectionState<Metadata>]
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
    func pick(host:Mongo.Host) -> Bool
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
