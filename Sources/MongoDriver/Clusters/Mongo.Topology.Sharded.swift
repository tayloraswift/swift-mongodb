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
    init?(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Router,
        seedlist:inout Mongo.Seedlist)
    {
        self.init(routers: seedlist.topology(of: Mongo.Router.self))
        guard case ()? = self.update(host: host, connection: connection, metadata: metadata)
        else
        {
            seedlist.pick(host: host)
            return nil
        }
    }
    mutating
    func remove(host:Mongo.Host) -> Void?
    {
        self.routers[host].remove()
        return nil
    }
    mutating
    func clear(host:Mongo.Host, status:(any Error)?) -> Void?
    {
        self.routers[host]?.clear(status: status)
    }
    mutating
    func update(host:Mongo.Host, connection:Mongo.Connection, metadata:Mongo.Router) -> Void?
    {
        self.routers[host]?.update(connection: connection, metadata: metadata)
    }
}
