extension Mongo
{
    public
    struct TransactionsUnsupportedError:Error, Equatable, Sendable
    {
        public
        init()
        {
        }
    }
}
