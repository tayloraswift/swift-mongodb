import Durations

extension MongoTopology
{
    @frozen public
    struct Replica:Sendable
    {
        /// The *estimated* amount of time until it is expected that the metadata
        /// for the relevant set member will be updated again. (The actual time
        /// may vary substantially.)
        ///
        /// This time is used to compute the staleness of secondaries for the
        /// purposes of server selection. It is *usually* globally consistent
        /// across all members of a replica set, but it is tracked independently
        /// for each data-bearing replica because set members are monitored
        /// asynchronously.
        public
        let heartbeatFrequency:Milliseconds
        public
        let timings:MongoTopology.Timings
        public
        let tags:[String: String]
    }
}
extension MongoTopology.Replica
{
    /// The formulaic staleness of this replica, assuming it is a secondary.
    /// This staleness value is only valid on secondary replicas.
    ///
    /// The staleness of a primary is always defined to be zero, whereas
    /// this method will always return a staleness that is at least
    /// ``heartbeatFrequency``.
    func staleness(freshest:MongoTopology.Members.Freshest) -> Milliseconds
    {
        self.heartbeatFrequency + self.timings.lag(behind: freshest)
    }
}
