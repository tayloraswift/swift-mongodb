import BSONDecoding
import Durations

extension MongoTopology
{
    /// The time when metadata for a server was last updated, and
    /// the time of the last write logged on the primary that has
    /// replicated to that server.
    public
    struct Timings:Sendable
    {
        public
        let update:ContinuousClock.Instant
        public
        let write:BSON.Millisecond

        public
        init(write:BSON.Millisecond)
        {
            self.update = .now
            self.write = write
        }
    }
}
extension MongoTopology.Timings
{
    func lag(behind freshest:MongoTopology.Members.Freshest) -> Milliseconds
    {
        //  https://github.com/mongodb/specifications/blob/master/source/max-staleness/max-staleness.rst#client
        switch freshest
        {
        case .primary(let rhs):
            //  the formula is:
            //
            //  (self.update - self.write) - (rhs.update - rhs.write)
            //
            //  but we cannot measure the duration between a
            //  ``ContinuousClock.Instant`` and a ``BSON.Millisecond``.
            //  so we rearrange terms to get:
            //
            //  ==  self.update - self.write - rhs.update + rhs.write
            //  ==  self.update - rhs.update - self.write + rhs.write
            //  == (self.update - rhs.update) - (self.write - rhs.write)
            let a:Milliseconds = .init(truncating: self.update - rhs.update)
            let b:Milliseconds = .init(rawValue: self.write.value - rhs.write.value)
            return a - b
        
        case .secondary(let lhs):
            //  note: `self` is the right-hand term
            return .init(rawValue: lhs.value - self.write.value)
        }
    }
}
extension MongoTopology.Timings:BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(write: try bson["lastWriteDate"].decode(to: BSON.Millisecond.self))
    }
}
