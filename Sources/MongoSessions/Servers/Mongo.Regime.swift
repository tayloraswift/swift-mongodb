import BSON

extension Mongo
{
    struct Regime:Hashable, Sendable
    {
        /// This is called ``electionId` in the server reply.
        let election:BSON.Identifier
        /// The current replica set version.
        /// This is called `setVersion` in the server reply.
        ///
        /// All set members, including slave members, receive a set version
        /// in their ``Hello`` response, but it is only meaningful for
        /// the primary member
        /// ([rationale](https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#ignore-setversion-unless-the-server-is-primary)).
        let version:Int64

        init(election:BSON.Identifier, version:Int64)
        {
            self.election = election
            self.version = version
        }
    }
}
extension Mongo.Regime:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.election, lhs.version) < (rhs.election, rhs.version)
    }
}
