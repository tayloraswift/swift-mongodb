import BSON
import Durations

extension Mongo.Replica
{
    @available(*, deprecated, renamed: "Mongo.PrimaryBaseline")
    public
    typealias PrimaryBaseline = Mongo.PrimaryBaseline
}

extension Mongo
{
    /// The time when metadata for a primary was last updated, and
    /// the time of the last write logged on that primary.
    @frozen public
    struct PrimaryBaseline:Sendable
    {
        public
        let update:ContinuousClock.Instant
        public
        let write:BSON.Millisecond

        @inlinable public
        init(update:ContinuousClock.Instant, write:BSON.Millisecond)
        {
            self.update = update
            self.write = write
        }
    }
}
extension Mongo.PrimaryBaseline
{
    @inlinable public
    init(_ last:Mongo.ReplicaTimings)
    {
        self.init(update: last.update, write: last.write)
    }
}
extension Mongo.PrimaryBaseline:Mongo.ReplicaTimingBaseline
{
    /// Estimates the amount by which the given `candidate` is lagging
    /// the primary, using the primary’s timings as a reference.
    ///
    /// https://github.com/mongodb/specifications/blob/master/source/max-staleness/max-staleness.rst#client
    @inlinable public static
    func - (self:Self, candidate:Mongo.ReplicaTimings) -> Milliseconds
    {
        //  the formula is:
        //
        //  (candidate.update - candidate.write) - (self.update - self.write)
        //
        //  but we cannot measure the duration between a
        //  ``ContinuousClock.Instant`` and a ``BSON.Millisecond``.
        //  so we rearrange terms to get:
        //
        //  ==  candidate.update - candidate.write - self.update + self.write
        //  ==  candidate.update - self.update - candidate.write + self.write
        //  == (candidate.update - self.update) - (candidate.write - self.write)
        let a:Milliseconds = .init(truncating: candidate.update - self.update)
        let b:Milliseconds = .init(rawValue: candidate.write.value - self.write.value)
        return a - b
    }
}
