import BSON

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
        /// The read concern that will be appended to the relevant command.
        let writeConcern:WriteConcern.Options?
        /// The read concern that will be appended to the relevant command.
        let readConcern:ReadConcern.Options?
        /// The transaction number and phase that will be appended to the
        /// relevant command.
        public
        let transaction:TransactionLabels?
        /// The read preference that will be appended to the relevant command.
        public
        let preference:ReadPreference?
        /// The session identifier that will be appended to the relevant command.
        public
        let session:SessionIdentifier

        init(clusterTime:ClusterTime?,
            writeConcern:WriteConcern.Options?,
            readConcern:ReadConcern.Options?,
            transaction:TransactionLabels?,
            preference:ReadPreference?,
            session:SessionIdentifier)
        {
            self.clusterTime = clusterTime
            self.writeConcern = writeConcern
            self.readConcern = readConcern
            self.transaction = transaction
            self.preference = preference
            self.session = session
        }
    }
}
