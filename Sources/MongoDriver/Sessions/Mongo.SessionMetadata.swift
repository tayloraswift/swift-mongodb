import Durations

extension Mongo
{
    /// Session metadata encompasses session state that persists across
    /// re-used server sessions.
    struct SessionMetadata:Identifiable, Sendable
    {
        var transaction:TransactionState
        var touched:ContinuousClock.Instant
        let id:SessionIdentifier

        init(transaction:TransactionState,
            touched:ContinuousClock.Instant,
            id:SessionIdentifier)
        {
            self.transaction = transaction
            self.touched = touched
            self.id = id
        }
    }
}
extension Mongo.SessionMetadata
{
    /// Returns the driver-side expiration time of this session, which is
    /// defined to be [`ttl - 1`]() minutes after the instant when this
    /// session was last ``touched``.
    func expiration(ttl:Minutes) -> ContinuousClock.Instant
    {
        //  use one-minute buffer:
        //  https://github.com/mongodb/specifications/blob/master/source/sessions/driver-sessions.rst#algorithm-to-acquire-a-serversession-instance-from-the-server-session-pool
        self.touched.advanced(by: .minutes(ttl - 1))
    }
}
