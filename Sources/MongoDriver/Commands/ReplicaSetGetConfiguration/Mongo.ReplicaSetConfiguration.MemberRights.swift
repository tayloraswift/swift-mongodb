extension Mongo.ReplicaSetConfiguration
{
    @frozen public
    enum MemberRights:Sendable
    {
        /// A configuration for a resident member. Residents can vote for primary,
        /// but cannot become primary. Residents can be hidden and delayed.
        case resident(ResidentRights)
        /// A configuration for an arbiter. Arbiters only exist to vote for primary,
        /// in order to break ties, and have no other settings.
        case arbiter
        /// A configuration for a citizen member. Citizens always cast at least
        /// one vote for primary, and can themselves become primary, based on their
        /// priority.
        case citizen(CitizenRights)
    }
}
