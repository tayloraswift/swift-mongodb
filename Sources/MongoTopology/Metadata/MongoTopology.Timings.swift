import BSONDecoding

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
extension MongoTopology.Timings:BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(write: try bson["lastWriteDate"].decode(to: BSON.Millisecond.self))
    }
}
