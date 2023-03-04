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
        init(_ phase:TransactionPhase?)
        {
            self.number = 0
            self.phase = phase
        }
    }
}
