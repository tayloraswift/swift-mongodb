import BSONEncoding

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
extension Mongo.AbortTransaction:MongoTransactableCommand, MongoCommand
{
    /// The string [`"abortTransaction"`]().
    @inlinable public static
    var name:String
    {
        "abortTransaction"
    }

    /// `AbortTransaction` must be run against the `admin` database.
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
