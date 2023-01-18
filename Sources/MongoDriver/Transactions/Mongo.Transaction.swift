extension Mongo
{
    @frozen public
    struct Transaction:Sendable
    {
        public
        var number:Int64
        public
        var phase:TransactionPhase?

        @inlinable public
        init()
        {
            self.number = 1
            self.phase = nil
        }
    }
}
