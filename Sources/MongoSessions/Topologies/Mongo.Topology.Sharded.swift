import MongoChannel

extension Mongo.Topology
{
    struct Sharded
    {
        private
        var routers:[Mongo.Host: MongoChannel.State<Mongo.Router>]

        private
        init(routers:[Mongo.Host: MongoChannel.State<Mongo.Router>])
        {
            self.routers = routers
        }
    }
}
extension Mongo.Topology.Sharded
{
    func terminate()
    {
        for router:MongoChannel.State<Mongo.Router> in self.routers.values
        {
            router.channel?.heart.stop()
        }
    }
    func errors() -> [Mongo.Host: any Error]
    {
        self.routers.compactMapValues(\.error)
    }
}
extension Mongo.Topology.Sharded
{
    init?(host:Mongo.Host, channel:MongoChannel, metadata:Mongo.Router,
        seedlist:inout Mongo.Seedlist)
    {
        self.init(routers: seedlist.topology(of: Mongo.Router.self))
        guard self.update(host: host, channel: channel, metadata: metadata)
        else
        {
            seedlist.pick(host: host)
            return nil
        }
    }
    mutating
    func remove(host:Mongo.Host) -> Bool
    {
        self.routers[host].remove()
    }
    mutating
    func clear(host:Mongo.Host, status:(any Error)?) -> Bool
    {
        self.routers[host]?.clear(status: status) ?? false
    }
    mutating
    func update(host:Mongo.Host, channel:MongoChannel, metadata:Mongo.Router) -> Bool
    {
        self.routers[host]?.update(channel: channel, metadata: metadata) ?? false
    }
}
extension Mongo.Topology.Sharded
{
    /// Returns a channel to any available router.
    var any:MongoChannel?
    {
        for router:MongoChannel.State<Mongo.Router> in self.routers.values
        {
            if let channel:MongoChannel = router.channel
            {
                return channel
            }
        }
        return nil
    }
}
