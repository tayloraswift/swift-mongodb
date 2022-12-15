extension Mongo
{
    struct Transaction
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
