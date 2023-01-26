extension Mongo
{
    @frozen public
    struct TransactionState:Sendable
    {
        public
        var number:Int64
        public
        var phase:TransactionPhase?

        @inlinable public
        init()
        {
            self.number = 0
            self.phase = nil
        }
    }
}
