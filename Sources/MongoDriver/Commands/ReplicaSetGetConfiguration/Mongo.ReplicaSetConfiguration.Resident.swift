import UnixTime

extension Mongo.ReplicaSetConfiguration
{
    /// A configuration for a resident member. Residents can vote for primary,
    /// but cannot become primary. Residents can be hidden and delayed.
    @frozen public
    struct Resident:Equatable, Sendable
    {
        public
        let buildsIndexes:Bool
        public
        let delay:Seconds?

        @inlinable public
        init(buildsIndexes:Bool = true,
            delay:Seconds? = nil)
        {
            self.buildsIndexes = buildsIndexes
            self.delay = delay
        }
    }
}
extension Mongo.ReplicaSetConfiguration.Resident
{
    /// If a resident is a delayed member, it is also hidden.
    /// If a resident is hidden but is not a delayed member,
    /// then it has a delay of zero.
    @inlinable public
    var isHidden:Bool
    {
        self.delay != nil
    }
    /// Returns [`0.0`](). Residents cannot become primary.
    @inlinable public
    var priority:Double
    {
        0.0
    }
}
