import MongoChannel

extension MongoTopology
{
    public
    struct Sharded
    {
        private
        var routers:[Host: MongoChannel.State<Router>]

        private
        init(routers:[Host: MongoChannel.State<Router>])
        {
            self.routers = routers
        }
    }
}
extension MongoTopology.Sharded
{
    func terminate()
    {
        for router:MongoChannel.State<MongoTopology.Router> in self.routers.values
        {
            router.channel?.heart.stop()
        }
    }
    func errors() -> [MongoTopology.Host: any Error]
    {
        self.routers.compactMapValues(\.error)
    }
}
extension MongoTopology.Sharded
{
    init?(host:MongoTopology.Host, channel:MongoChannel,
        metadata:MongoTopology.Router,
        seedlist:inout MongoTopology.Unknown)
    {
        self.init(routers: seedlist.topology(of: MongoTopology.Router.self))
        guard self.update(host: host, channel: channel, metadata: metadata)
        else
        {
            seedlist.pick(host: host)
            return nil
        }
    }
    mutating
    func remove(host:MongoTopology.Host) -> Bool
    {
        self.routers[host].remove()
    }
    mutating
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
    {
        self.routers[host]?.clear(status: status) ?? false
    }
    mutating
    func update(host:MongoTopology.Host, channel:MongoChannel,
        metadata:MongoTopology.Router) -> Bool
    {
        self.routers[host]?.update(channel: channel, metadata: metadata) ?? false
    }
}
extension MongoTopology.Sharded
{
    /// Returns a channel to any available router.
    public
    var any:MongoChannel?
    {
        for router:MongoChannel.State<MongoTopology.Router> in self.routers.values
        {
            if let channel:MongoChannel = router.channel
            {
                return channel
            }
        }
        return nil
    }
}
