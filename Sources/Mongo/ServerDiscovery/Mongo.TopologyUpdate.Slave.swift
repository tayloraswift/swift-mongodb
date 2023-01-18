extension Mongo.TopologyUpdate
{
    /// An update about about a replica set member that believes it
    /// is not the ``case Member.primary(_:)``.
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
        case .secondary(let replica):   return .secondary(replica)
        case .arbiter:                  return .arbiter
        case .other:                    return .other
        }
    }
}
