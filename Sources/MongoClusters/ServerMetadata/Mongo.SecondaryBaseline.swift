import BSON
import UnixTime

extension Mongo
{
    /// The time when metadata for a secondary was last updated, and
    /// the time of the last write logged on its primary that has
    /// replicated to that secondary.
    @frozen public
    struct SecondaryBaseline:Sendable
    {
        public
        let write:UnixMillisecond

        @inlinable public
        init(write:UnixMillisecond)
        {
            self.write = write
        }
    }
}
extension Mongo.SecondaryBaseline
{
    @inlinable public
    init(_ last:Mongo.ReplicaTimings)
    {
        self.init(write: last.write)
    }
}
extension Mongo.SecondaryBaseline:Mongo.ReplicaTimingBaseline
{
    /// Estimates the amount by which the given `candidate` is lagging
    /// the primary, using the freshest secondary’s timings as a reference.
    ///
    /// https://github.com/mongodb/specifications/blob/master/source/max-staleness/max-staleness.rst#client
    @inlinable public static
    func - (self:Self, candidate:Mongo.ReplicaTimings) -> Milliseconds
    {
        //  formula is like the one with a primary reference, except
        //  we get rid of the “update” terms.
        //
        //      (0 - candidate.write) - (0 - self.write)
        self.write - candidate.write
    }
}
