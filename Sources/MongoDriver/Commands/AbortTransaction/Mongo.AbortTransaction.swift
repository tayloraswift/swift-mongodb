import BSON

extension Mongo
{
    /// The MongoDB `abortTransaction` command.
    ///
    /// This command is internal because the driver manages transactions
    /// automatically.
    struct AbortTransaction:Equatable, Sendable
    {
        let writeConcern:WriteConcern?

        init(writeConcern:WriteConcern?,
            location:SourceLocation = (#fileID, #line))
        {
            self.writeConcern = writeConcern
        }
    }
}
extension Mongo.AbortTransaction:Mongo.TransactableCommand, Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .abortTransaction }

    /// `AbortTransaction` must be run against the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    var fields:BSON.Document
    {
        Self.type(nil)
    }
}
