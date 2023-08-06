import BSON
import Durations

extension Mongo.Replica
{
    /// The time when metadata for a secondary was last updated, and
    /// the time of the last write logged on its primary that has
    /// replicated to that secondary.
    @frozen public
    struct SecondaryBaseline:Sendable
    {
        public
        let write:BSON.Millisecond

        @inlinable public
        init(write:BSON.Millisecond)
        {
            self.write = write
        }
    }
}
extension Mongo.Replica.SecondaryBaseline
{
    @inlinable public
    init(_ last:Mongo.Replica.Timings)
    {
        self.init(write: last.write)
    }
}
extension Mongo.Replica.SecondaryBaseline
{
    /// Estimates the amount by which the given `candidate` is lagging 
    /// the primary, using the freshest secondary’s timings as a reference.
    ///
    /// https://github.com/mongodb/specifications/blob/master/source/max-staleness/max-staleness.rst#client
    @inlinable public static
    func - (self:Self, candidate:Mongo.Replica.Timings) -> Milliseconds
    {
        //  formula is like the one with a primary reference, except
        //  we get rid of the “update” terms.
        //
        //      (0 - candidate.write) - (0 - self.write)
        return .init(rawValue: self.write.value - candidate.write.value)
    }
}
