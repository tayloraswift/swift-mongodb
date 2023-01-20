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
            self.number = 0
            self.phase = nil
        }
    }
}
extension Mongo.Transaction
{
    public mutating
    func start()
    {
        if case nil = self.phase
        {
            self.number += 1
            self.phase = .starting
        }
        else
        {
            fatalError("MongoDB transaction misuse: cannot start a transaction from within another transaction!")
        }
    }
}
