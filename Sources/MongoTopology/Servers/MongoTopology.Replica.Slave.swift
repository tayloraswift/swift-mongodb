import BSON

extension MongoTopology.Replica
{
    /// Metadata about a slave replica. Note that a slave replica will never be
    /// the ``case primary(_:)``, but slavery does not imply that the replica is
    /// a readable ``case secondary(_:)``.
    public
    struct Slave:Sendable
    {
        public
        let tags:BSON.Fields
        /// The name of the current replica set.
        /// This is called `setName` in the server reply.
        public
        let set:String

        @inlinable public
        init(tags:BSON.Fields,
            set:String)
        {
            self.tags = tags
            self.set = set
        }
    }
}
