import MongoMonitoring

extension Mongo.Topology
{
    public
    struct Sharded
    {
        private
        var routers:[Mongo.Host: Mongo.ServerDescription<Mongo.Router, Owner>]

        private
        init(routers:[Mongo.Host: Mongo.ServerDescription<Mongo.Router, Owner>])
        {
            self.routers = routers
        }
    }
}
extension Mongo.Topology.Sharded:Sendable where Owner:Sendable
{
}
extension Mongo.Topology.Sharded:Sequence
{
    public
    func makeIterator() -> Dictionary<Mongo.Host,
        Mongo.ServerDescription<Mongo.Router, Owner>>.Iterator
    {
        self.routers.makeIterator()
    }
}
extension Mongo.Topology.Sharded
{
    public
    subscript(host:Mongo.Host) -> Mongo.ServerDescription<Mongo.Router, Owner>?
    {
        _read
        {
            yield  self.routers[host]
        }
        _modify
        {
            yield &self.routers[host]
        }
    }
}
extension Mongo.Topology.Sharded
{
    init(from unknown:Mongo.Topology<Owner>.Unknown)
    {
        self.init(routers: unknown.topology(of: Mongo.Router.self))
    }
}
