extension Mongo
{
    struct SessionMetadata
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
