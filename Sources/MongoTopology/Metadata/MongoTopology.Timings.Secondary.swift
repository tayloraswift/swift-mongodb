import BSON
import Durations

extension MongoTopology.Timings
{
    /// The time when metadata for a secondary was last updated, and
    /// the time of the last write logged on its primary that has
    /// replicated to that secondary.
    struct Secondary:Sendable
    {
        let write:BSON.Millisecond

        init(write:BSON.Millisecond)
        {
            self.write = write
        }
    }
}
extension MongoTopology.Timings.Secondary
{
    init(_ untyped:MongoTopology.Timings)
    {
        self.init(write: untyped.write)
    }
}
extension MongoTopology.Timings.Secondary
{
    /// Estimates the amount by which the given `candidate` is lagging 
    /// the primary, using the freshest secondary’s timings as a reference.
    ///
    /// https://github.com/mongodb/specifications/blob/master/source/max-staleness/max-staleness.rst#client
    static
    func - (self:Self, candidate:MongoTopology.Timings) -> Milliseconds
    {
        //  formula is like the one with a primary reference, except
        //  we get rid of the “update” terms.
        //
        //      (0 - candidate.write) - (0 - self.write)
        return .init(rawValue: self.write.value - candidate.write.value)
    }
}
