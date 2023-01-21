extension Mongo
{
    public
    struct TransactionContext
    {
        public
        let session:Session
        let pinned:ConnectionPool

        @usableFromInline
        init(session:Session, pinned:ConnectionPool)
        {
            self.session = session
            self.pinned = pinned
        }
    }
}
