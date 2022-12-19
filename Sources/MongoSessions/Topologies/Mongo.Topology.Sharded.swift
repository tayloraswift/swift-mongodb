extension Mongo.Topology
{
    struct Sharded
    {
        private
        var routers:[Mongo.Host: Mongo.ConnectionState<Mongo.Router>]

        private
        init(routers:[Mongo.Host: Mongo.ConnectionState<Mongo.Router>])
        {
            self.routers = routers
        }
    }
}
extension Mongo.Topology.Sharded
{
    func terminate()
    {
        for router:Mongo.ConnectionState<Mongo.Router> in self.routers.values
        {
            router.connection?.heart.stop()
        }
    }
    func errors() -> [Mongo.Host: any Error]
    {
        self.routers.compactMapValues(\.error)
    }
}
extension Mongo.Topology.Sharded
{
    init?(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Router,
        seedlist:inout Mongo.Seedlist)
    {
        self.init(routers: seedlist.topology(of: Mongo.Router.self))
        guard self.update(host: host, connection: connection, metadata: metadata)
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
    func update(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Router) -> Bool
    {
        self.routers[host]?.update(connection: connection, metadata: metadata) ?? false
    }
}
extension Mongo.Topology.Sharded
{
    /// Returns a connection to any available router.
    var any:Mongo.Connection?
    {
        for router:Mongo.ConnectionState<Mongo.Router> in self.routers.values
        {
            if let connection:Mongo.Connection = router.connection
            {
                return connection
            }
        }
        return nil
    }
}
