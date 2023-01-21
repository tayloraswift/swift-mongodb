import BSONEncoding

extension Mongo
{
    /// The MongoDB `abortTransaction` command.
    @usableFromInline
    struct AbortTransaction:Equatable, Sendable
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
