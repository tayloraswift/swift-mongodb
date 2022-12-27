extension Mongo
{
    /// Session metadata encompasses session state that persists across
    /// re-used server sessions.
    @usableFromInline
    struct SessionMetadata:Sendable
    {
        @usableFromInline
        var transaction:Transaction
        @usableFromInline
        var touched:ContinuousClock.Instant

        init(touched:ContinuousClock.Instant)
        {
            self.transaction = .init()
            self.touched = touched
        }
    }
}
