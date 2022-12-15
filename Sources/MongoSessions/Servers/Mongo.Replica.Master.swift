import BSON

extension Mongo.Replica
{
    /// Metadata about a master replica. Master replicas believe they are
    /// the ``case primary(_:)``.
    struct Master
    {
        let regime:Mongo.Regime
        let tags:BSON.Fields
        /// The name of the current replica set.
        /// This is called `setName` in the server reply.
        let set:String
    }
}
