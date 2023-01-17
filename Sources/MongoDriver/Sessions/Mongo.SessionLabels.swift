import BSONEncoding

extension Mongo
{
    public
    struct SessionLabels
    {
        public
        let clusterTime:ClusterTime
        public
        let readPreference:ReadPreference?
        public
        let readConcern:ReadConcern?
        public
        let transaction:Transaction
        public
        let session:SessionIdentifier

        public
        init(clusterTime:ClusterTime,
            readPreference:ReadPreference?,
            readConcern:ReadConcern?,
            transaction:Transaction,
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
