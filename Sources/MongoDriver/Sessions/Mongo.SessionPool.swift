extension Mongo
{
    enum TransactionState
    {
        case started
        case aborted
        case committed
    }
}
extension Mongo
{
    struct Transaction
    {
        var number:Int64
        var state:TransactionState?

        init()
        {
            self.number = 1
            self.state = nil
        }
    }
}
extension Mongo
{
    struct SessionState
    {
        var transaction:Transaction
        var touched:ContinuousClock.Instant
    }
}
extension Mongo
{
    struct SessionMetadata
    {
        let id:SessionIdentifier
        var state:SessionState
    }
}
extension Mongo
{
    struct SessionContext
    {
        let connection:Mongo.Connection
        let timeout:Mongo.Minutes
    }
}
extension Mongo
{
    struct SessionPool
    {
        private(set)
        var available:[SessionIdentifier: SessionState]
        private(set)
        var claimed:Set<SessionIdentifier>

        init()
        {
            self.available = [:]
            self.claimed = []
        }
    }
}
extension Mongo.SessionPool
{
    mutating
    func checkout(context:Mongo.SessionContext) -> Mongo.SessionMetadata
    {
        let now:ContinuousClock.Instant = .now
        while case let (id, session)? = self.available.popFirst()
        {
            if now < session.touched.advanced(by: .minutes(context.timeout - 1))
            {
                self.claimed.update(with: id)
                return .init(id: id, state: session)
            }
        }
        // very unlikely, but do not generate a session id that we have
        // already generated. this is not foolproof (because we could
        // have persistent sessions from a previous run), but allows us
        // to maintain local dictionary invariants.
        while true
        {
            let id:Mongo.SessionIdentifier = .random()
            if case nil = self.claimed.update(with: id)
            {
                return .init(id: id, state: .init(transaction: .init(), touched: now))
            }
        }
    }
    mutating
    func checkin(_ session:Mongo.SessionMetadata)
    {
        guard case _? = self.claimed.remove(session.id)
        else
        {
            fatalError("unreachable: released an unknown session! (\(session.id))")
        }
        guard case nil = self.available.updateValue(session.state, forKey: session.id)
        else
        {
            fatalError("unreachable: released an duplicate session! (\(session.id))")
        }
    }
}
