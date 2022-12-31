import MongoChannel
import MongoConnection

extension MongoTopology
{
    public
    struct Sharded
    {
        private
        var routers:[Host: MongoConnection<Router>.State]

        private
        init(routers:[Host: MongoConnection<Router>.State])
        {
            self.routers = routers
        }
    }
}
extension MongoTopology.Sharded
{
    func terminate()
    {
        for router:MongoConnection<MongoTopology.Router>.State in self.routers.values
        {
            router.connection?.channel.heart.stop()
        }
    }
    // func errors() -> [MongoTopology.Host: any Error]
    // {
    //     self.routers.compactMapValues(\.error)
    // }
}
extension MongoTopology.Sharded
{
    var servers:MongoTopology.Routers
    {
        var servers:MongoTopology.Routers = .init()
        for (host, router):(MongoTopology.Host, MongoConnection<MongoTopology.Router>.State)
            in self.routers
        {
            servers.append(router: router, host: host)
        }
        return servers
    }
}
extension MongoTopology.Sharded
{
    init(from unknown:MongoTopology.Unknown)
    {
        self.init(routers: unknown.topology(of: MongoTopology.Router.self))
    }
    mutating
    func remove(host:MongoTopology.Host) -> Bool
    {
        self.routers[host].remove()
        return false
    }
    mutating
    func clear(host:MongoTopology.Host, status:(any Error)?) -> Bool
    {
        if  case ()? = self.routers[host]?.clear(status: status)
        {
            return true
        }
        else
        {
            return false
        }
    }
    mutating
    func update(host:MongoTopology.Host, metadata:MongoTopology.Router,
        channel:MongoChannel) -> Bool
    {
        if  case ()? = self.routers[host]?.update(with: .init(
                metadata: metadata,
                channel: channel))
        {
            return true
        }
        else
        {
            return false
        }
    }
}
extension MongoTopology.Sharded
{
    /// Returns a channel to any available router.
    // public
    // var nearest:MongoChannel?
    // {
    //     for router:MongoConnection<MongoTopology.Router>.State in self.routers.values
    //     {
    //         if let channel:MongoChannel = router.channel
    //         {
    //             return channel
    //         }
    //     }
    //     return nil
    // }
}
