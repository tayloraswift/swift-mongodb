extension Mongo
{
    @frozen public
    struct TransactionLabels
    {
        public
        let transaction:Transaction
        public
        let session:SessionIdentifier

        init(transaction:Transaction, session:SessionIdentifier)
        {
            self.transaction = transaction
            self.session = session
        }
    }
}
