extension Mongo
{
    public
    struct TransactionInProgressError:Error, Equatable, Sendable
    {
        public
        init()
        {
        }
    }
}
