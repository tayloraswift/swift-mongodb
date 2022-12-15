extension Mongo
{
    @usableFromInline
    struct Transaction:Sendable
    {
        var number:Int64
        var phase:TransactionPhase?

        init()
        {
            self.number = 1
            self.phase = nil
        }
    }
}
