import BSONEncoding

extension Mongo
{
    @frozen public
    struct Labeled<Command> where Command:MongoSessionCommand
    {
        @usableFromInline
        let clusterTime:ClusterTime?
        @usableFromInline
        let readConcern:ReadConcern?
        @usableFromInline
        let transaction:Transaction
        public
        let session:SessionIdentifier
        public
        let command:Command

        @usableFromInline
        init(clusterTime:ClusterTime?, readConcern:ReadConcern?, transaction:Transaction,
            session:SessionIdentifier,
            command:Command)
        {
            self.clusterTime = clusterTime
            self.readConcern = readConcern
            self.transaction = transaction
            self.session = session
            self.command = command
        }
    }
}
extension Mongo.Labeled
{
    @inlinable public
    func encode(to bson:inout BSON.Fields, database:Mongo.Database)
    {
        self.command.encode(to: &bson, database: database)

        bson["lsid"] = self.session
        bson["readConcern"] = self.readConcern
        bson["$clusterTime"] = self.clusterTime

        guard let phase:Mongo.TransactionPhase = self.transaction.phase
        else
        {
            return
        }

        bson["txnNumber"] = self.transaction.number
        bson["autocommit"] = false

        guard case .starting = phase
        else
        {
            return
        }

        bson["startTransaction"] = true
    }
}
