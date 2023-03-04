extension Mongo.TopologyUpdate
{
    /// An update about about a replica set member that believes it
    /// is the primary.
    public
    struct Primary:Sendable
    {
        private
        let replica:Mongo.Replica
        private
        let term:Mongo.ReplicaSetTerm

        public
        init(replica:Mongo.Replica, term:Mongo.ReplicaSetTerm)
        {
            self.replica = replica
            self.term = term
        }
    }
}
extension Mongo.TopologyUpdate.Primary
{
    var metadata:Mongo.ReplicaSetMember
    {
        .primary(self.replica)
    }

    /// Checks if the update is newer than the specified term,
    /// and if so, sets the parameter to the newer term.
    /// A nil term always compares older than any update;
    /// therefore the parameter will always be non-nil after
    /// calling this function.
    func newer(than term:inout Mongo.ReplicaSetTerm?) -> Bool
    {
        if  let term:Mongo.ReplicaSetTerm, self.term < term
        {
            return false
        }
        else
        {
            term = self.term
            return true
        }
    }
}
