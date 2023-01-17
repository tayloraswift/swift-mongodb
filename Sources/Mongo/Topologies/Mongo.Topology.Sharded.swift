import MongoMonitoring

extension Mongo.Topology
{
    public
    struct Sharded
    {
        public private(set)
        var routers:[Mongo.Host: Mongo.ServerDescription<Mongo.Router, Pool>]

        private
        init(routers:[Mongo.Host: Mongo.ServerDescription<Mongo.Router, Pool>])
        {
            self.routers = routers
        }
    }
}
extension Mongo.Topology.Sharded
{
    init(from unknown:Mongo.Topology<Pool>.Unknown)
    {
        self.init(routers: unknown.topology(of: Mongo.Router.self))
    }
    mutating
    func remove(host:Mongo.Host) -> Bool
    {
        self.routers[host].remove()
        return false
    }
    mutating
    func combine(error status:(any Error)?, host:Mongo.Host) -> Bool
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
    func combine(metadata:Mongo.Router, host:Mongo.Host, pool:Pool) -> Bool
    {
        if  case ()? = self.routers[host]?.update(with: metadata, pool: pool)
        {
            return true
        }
        else
        {
            return false
        }
    }
}
