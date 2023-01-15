import Atomics
import Durations

extension Mongo
{
    @frozen public
    struct LogicalSessions:Sendable
    {
        /// The time that a
        /// [session](https://www.mongodb.com/docs/manual/core/read-isolation-consistency-recency/#std-label-sessions)
        /// remains active after its most recent use. Sessions that have not received
        /// a new read/write operation from the client or been refreshed with
        /// [`refreshSessions`](https://www.mongodb.com/docs/manual/reference/command/refreshSessions/#mongodb-dbcommand-dbcmd.refreshSessions)
        /// within this threshold are cleared from the cache. State associated with
        /// an expired session may be cleaned up by the server at any time.
        public
        let ttl:Minutes

        @inlinable public
        init(ttl:Minutes)
        {
            self.ttl = ttl
        }
    }
}
extension Mongo.LogicalSessions:AtomicValue
{
}
extension Mongo.LogicalSessions:RawRepresentable
{
    @inlinable public
    var rawValue:Minutes.RawValue
    {
        self.ttl.rawValue
    }
    @inlinable public
    init(rawValue:Minutes.RawValue)
    {
        self.init(ttl: .init(rawValue: rawValue))
    }
}
