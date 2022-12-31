extension MongoTopology
{
    @frozen public
    enum Servers
    {
        /// No servers are reachable, desirable, or suitable. The
        /// ``case MongoTopology/.unknown(_:)`` topology always generates
        /// this value, but the ``case MongoTopology/.single(_:)`` topology
        /// can also generate if its sole server is unreachable.
        case none([Rejection<Unreachable>])
        case single(Server<Standalone>)
        case sharded(Routers)
        case replicated(Replicas)
    }
}
