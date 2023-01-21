import BSONEncoding

extension Mongo
{
    /// Labels to be added to a command run as part of a logical session.
    public
    struct SessionLabels
    {
        /// The notarized cluster time that will be appended to the relevant
        /// command.
        public
        let clusterTime:ClusterTime?
        /// The read preference that will be appended to the relevant command.
        public
        let readPreference:ReadPreference?
        /// The read concern that will be appended to the relevant command.
        public
        let readConcern:ReadConcern?
        /// The transaction number and phase that will be appended to the
        /// relevant command.
        public
        let transaction:TransactionLabels?
        /// The session identifier that will be appended to the relevant command.
        public
        let session:SessionIdentifier

        public
        init(clusterTime:ClusterTime?,
            readPreference:ReadPreference?,
            readConcern:ReadConcern?,
            transaction:TransactionLabels?,
            session:SessionIdentifier)
        {
            self.clusterTime = clusterTime
            self.readPreference = readPreference
            self.readConcern = readConcern
            self.transaction = transaction
            self.session = session
        }
    }
}
