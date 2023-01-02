import BSON
import Durations

extension MongoTopology.Timings
{
    /// The time when metadata for a primary was last updated, and
    /// the time of the last write logged on that primary.
    struct Primary:Sendable
    {
        let update:ContinuousClock.Instant
        let write:BSON.Millisecond

        init(update:ContinuousClock.Instant, write:BSON.Millisecond)
        {
            self.update = update
            self.write = write
        }
    }
}
extension MongoTopology.Timings.Primary
{
    init(_ untyped:MongoTopology.Timings)
    {
        self.init(update: untyped.update, write: untyped.write)
    }
}
extension MongoTopology.Timings.Primary
{
    /// Estimates the amount by which the given `candidate` is lagging 
    /// the primary, using the primary’s timings as a reference.
    ///
    /// https://github.com/mongodb/specifications/blob/master/source/max-staleness/max-staleness.rst#client
    static
    func - (self:Self, candidate:MongoTopology.Timings) -> Milliseconds
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
