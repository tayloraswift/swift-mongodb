import BSON

extension MongoTopology
{
    public
    struct Regime:Hashable, Sendable
    {
        /// This is called ``electionId` in the server reply.
        public
        let election:BSON.Identifier
        /// The current replica set version.
        /// This is called `setVersion` in the server reply.
        ///
        /// All set members, including slave members, receive a set version
        /// in their ``Hello`` response, but it is only meaningful for
        /// the primary member
        /// ([rationale](https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#ignore-setversion-unless-the-server-is-primary)).
        public
        let version:Int64

        @inlinable public
        init(election:BSON.Identifier, version:Int64)
        {
            self.election = election
            self.version = version
        }
    }
}
extension MongoTopology.Regime:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        (lhs.election, lhs.version) < (rhs.election, rhs.version)
    }
}
