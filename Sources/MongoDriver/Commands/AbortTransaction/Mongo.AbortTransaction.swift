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

        init(writeConcern:WriteConcern?)
        {
            self.writeConcern = writeConcern
        }
    }
}
extension Mongo.AbortTransaction:MongoTransactableCommand, MongoCommand
{
    /// `AbortTransaction` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    /// The string [`"abortTransaction"`]().
    @inlinable public static
    var name:String
    {
        "abortTransaction"
    }

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = 1 as Int32
        bson["writeConcern"] = self.writeConcern
    }
}
