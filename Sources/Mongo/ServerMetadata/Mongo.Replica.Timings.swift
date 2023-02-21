import BSONDecoding

extension Mongo.Replica
{
    /// The time when metadata for a server was last updated, and
    /// the time of the last write logged on the primary that has
    /// replicated to that server.
    @frozen public
    struct Timings:Sendable
    {
        public
        let update:ContinuousClock.Instant
        public
        let write:BSON.Millisecond

        @inlinable public
        init(write:BSON.Millisecond)
        {
            self.update = .now
            self.write = write
        }
    }
}
extension Mongo.Replica.Timings:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.UniversalKey, some RandomAccessCollection<UInt8>>)
        throws
    {
        self.init(write: try bson["lastWriteDate"].decode(to: BSON.Millisecond.self))
    }
}
