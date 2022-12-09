import BSON

extension Mongo.Replica
{
    /// Metadata about a slave replica. Note that a slave replica will never be
    /// the ``case primary(_:)``, but slavery does not imply that the replica is
    /// a readable ``case secondary(_:)``.
    struct Slave
    {
        let tags:BSON.Fields
        /// The name of the current replica set.
        /// This is called `setName` in the server reply.
        let set:String
    }
}
