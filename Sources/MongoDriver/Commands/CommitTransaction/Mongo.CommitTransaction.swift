import BSONEncoding

extension Mongo
{
    /// The MongoDB `commitTransaction` command.
    ///
    /// This command is internal because the driver manages transactions
    /// automatically.
    struct CommitTransaction:Sendable
    {
        let writeConcern:WriteConcern?

        init(writeConcern:WriteConcern?)
        {
            self.writeConcern = writeConcern
        }
    }
}
extension Mongo.CommitTransaction:MongoTransactableCommand, MongoCommand
{
    /// `CommitTransaction` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    /// The string [`"commitTransaction"`]().
    @inlinable public static
    var name:String
    {
        "commitTransaction"
    }

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = 1 as Int32
        bson["writeConcern"] = self.writeConcern
    }
}
