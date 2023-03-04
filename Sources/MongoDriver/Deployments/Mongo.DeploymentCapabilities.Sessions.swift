import Durations

extension Mongo.DeploymentCapabilities
{
    @frozen public
    struct Sessions:RawRepresentable, Sendable
    {
        //  This is backed by a ``UInt32`` and not ``Minutes``, because
        //  we want to guarantee encoding it into a ``DeploymentCapabilities``
        //  won’t crash on integer overflow.
        public
        var rawValue:UInt32

        @inlinable public
        init(rawValue:UInt32)
        {
            self.rawValue = rawValue
        }
    }
}
extension Mongo.DeploymentCapabilities.Sessions
{
    /// The time that a
    /// [session](https://www.mongodb.com/docs/manual/core/read-isolation-consistency-recency/#std-label-sessions)
    /// remains active after its most recent use. Sessions that have not received
    /// a new read/write operation from the client or been refreshed with
    /// [`refreshSessions`](https://www.mongodb.com/docs/manual/reference/command/refreshSessions/#mongodb-dbcommand-dbcmd.refreshSessions)
    /// within this threshold are cleared from the cache. State associated with
    /// an expired session may be cleaned up by the server at any time.
    var ttl:Minutes
    {
        .init(rawValue: .init(self.rawValue))
    }
}
