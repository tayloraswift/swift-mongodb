import BSON

extension MongoTopology.Replica
{
    /// Metadata about a master replica. Master replicas believe they are
    /// the ``case primary(_:)``.
    public
    struct Master:Sendable
    {
        public
        let regime:MongoTopology.Regime
        public
        let tags:BSON.Fields
        /// The name of the current replica set.
        /// This is called `setName` in the server reply.
        public
        let set:String

        @inlinable public
        init(regime:MongoTopology.Regime,
            tags:BSON.Fields,
            set:String)
        {
            self.regime = regime
            self.tags = tags
            self.set = set
        }
    }
}
