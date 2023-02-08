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
extension Mongo.CommitTransaction:MongoWriteCommand
{
}
extension Mongo.CommitTransaction:MongoTransactableCommand, MongoCommand
{
    /// `CommitTransaction` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    var fields:BSON.Fields
    {
        .init
        {
            $0[Self.name] = 1 as Int32
        }
    }

    /// The string [`"commitTransaction"`]().
    @inlinable public static
    var name:String
    {
        "commitTransaction"
    }
}
