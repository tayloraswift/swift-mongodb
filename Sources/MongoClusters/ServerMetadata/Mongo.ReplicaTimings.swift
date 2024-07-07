import BSON
import UnixTime

extension Mongo
{
    /// The time when metadata for a server was last updated, and the time of the last write
    /// logged on the primary that has replicated to that server. Not to be confused with
    /// replica latency.
    @frozen public
    struct ReplicaTimings:Sendable
    {
        public
        let update:ContinuousClock.Instant
        public
        let write:UnixMillisecond

        @inlinable public
        init(write:UnixMillisecond)
        {
            self.update = .now
            self.write = write
        }
    }
}
extension Mongo.ReplicaTimings:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key>) throws
    {
        self.init(write: try bson["lastWriteDate"].decode(to: UnixMillisecond.self))
    }
}
