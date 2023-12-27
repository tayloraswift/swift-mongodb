import BSON

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
extension Mongo.CommitTransaction:Mongo.TransactableCommand, Mongo.Command
{
    /// The string `"commitTransaction"`.
    @inlinable public static
    var type:Mongo.CommandType { .commitTransaction }

    /// `CommitTransaction` must be run against to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    var fields:BSON.Document
    {
        Self.type(1 as Int32)
    }
}
