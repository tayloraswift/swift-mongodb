extension Mongo
{
    public
    struct SessionMetadata:Sendable
    {
        var transaction:Transaction
        var touched:ContinuousClock.Instant

        init(touched:ContinuousClock.Instant)
        {
            self.transaction = .init()
            self.touched = touched
        }
    }
}
