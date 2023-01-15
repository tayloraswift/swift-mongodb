extension Mongo.TopologyUpdate
{
    /// An update about about a replica set member that believes it
    /// is the ``case Member.primary(_:)``.
    public
    struct Master:Sendable
    {
        public
        let replica:Mongo.Replica
        public
        let term:Mongo.ReplicaSetTerm

        public
        init(replica:Mongo.Replica, term:Mongo.ReplicaSetTerm)
        {
            self.replica = replica
            self.term = term
        }
    }
}
extension Mongo.TopologyUpdate.Master
{
    var metadata:Mongo.ReplicaSetMember
    {
        .primary(self.replica)
    }
}
