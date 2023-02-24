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
extension Mongo.CommitTransaction:MongoTransactableCommand, MongoSessionCommand
{
    /// The string [`"commitTransaction"`]().
    @inlinable public static
    var name:String
    {
        "commitTransaction"
    }

    /// `CommitTransaction` must be run against to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    var fields:BSON.Document
    {
        .init
        {
            $0[Self.name] = 1 as Int32
        }
    }
}
