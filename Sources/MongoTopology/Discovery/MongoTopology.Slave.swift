import BSONUnions
import Durations

extension MongoTopology
{
    /// An update about about a replica set member that believes it
    /// is not the ``case Member.primary(_:)``.
    @frozen public
    enum Slave:Sendable
    {
        case secondary(Replica)
        case arbiter
        case other
    }
}
extension MongoTopology.Slave
{
    var metadata:MongoTopology.Member
    {
        switch self
        {
        case .secondary(let replica):   return .secondary(replica)
        case .arbiter:                  return .arbiter
        case .other:                    return .other
        }
    }
}
