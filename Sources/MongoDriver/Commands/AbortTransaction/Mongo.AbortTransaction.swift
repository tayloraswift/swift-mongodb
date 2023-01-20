import BSONEncoding

extension Mongo
{
    /// The MongoDB `abortTransaction` command.
    ///
    /// This command conforms to ``Error``, and can be used to abort
    /// a transaction from within a transaction context with a specific
    /// write concern.
    public
    struct AbortTransaction:Equatable, Sendable, Error
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
extension Mongo.AbortTransaction:MongoCommand
{
    /// `AbortTransaction` must be sent to the `admin` database.
    public
    typealias Database = Mongo.Database.Admin

    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["abortTransaction"] = 1 as Int32
        bson["writeConcern"] = self.writeConcern
    }
}
