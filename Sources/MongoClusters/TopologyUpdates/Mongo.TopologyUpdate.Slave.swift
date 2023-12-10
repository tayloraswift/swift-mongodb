extension Mongo.TopologyUpdate
{
    /// An update about about a replica set member that believes it
    /// is a slave.
    @frozen public
    enum Slave:Sendable
    {
        case secondary(Mongo.Replica)
        case arbiter
        case other
    }
}
extension Mongo.TopologyUpdate.Slave
{
    var metadata:Mongo.ReplicaSetMember
    {
        switch self
        {
        case .secondary(let replica):   .secondary(replica)
        case .arbiter:                  .arbiter
        case .other:                    .other
        }
    }
}
