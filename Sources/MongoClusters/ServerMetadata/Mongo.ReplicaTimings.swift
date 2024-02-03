import BSON

extension Mongo.Replica
{
    @available(*, deprecated, renamed: "Mongo.ReplicaTimings")
    public
    typealias Timings = Mongo.ReplicaTimings
}
extension Mongo
{
    /// The time when metadata for a server was last updated, and
    /// the time of the last write logged on the primary that has
    /// replicated to that server.
    @frozen public
    struct ReplicaTimings:Sendable
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
extension Mongo.ReplicaTimings:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key, some RandomAccessCollection<UInt8>>)
        throws
    {
        self.init(write: try bson["lastWriteDate"].decode(to: BSON.Millisecond.self))
    }
}
