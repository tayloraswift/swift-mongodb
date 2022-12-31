import BSON
import Durations

extension MongoTopology
{
    /// An update about about a replica set member that believes it
    /// is the ``case Member.primary(_:)``.
    public
    struct Master:Sendable
    {
        public
        let replica:Replica
        public
        let regime:MongoTopology.Regime

        @inlinable public
        init(replica:Replica, regime:MongoTopology.Regime)
        {
            self.replica = replica
            self.regime = regime
        }
    }
}
extension MongoTopology.Master
{
    var metadata:MongoTopology.Member
    {
        .primary(self.replica)
    }
}
