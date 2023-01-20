import BSONEncoding

extension Mongo
{
    /// The MongoDB `commitTransaction` command.
    ///
    /// This command is internal because the driver manages transactions
    /// automatically.
    @usableFromInline
    struct CommitTransaction:Sendable
    {
        public
        let writeConcern:WriteConcern?

        public
        init(writeConcern:WriteConcern?)
        {
            self.writeConcern = writeConcern
        }
    }
}
extension Mongo.CommitTransaction:MongoCommand
{
    /// `CommitTransaction` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["commitTransaction"] = 1 as Int32
        bson["writeConcern"] = self.writeConcern
    }
}
