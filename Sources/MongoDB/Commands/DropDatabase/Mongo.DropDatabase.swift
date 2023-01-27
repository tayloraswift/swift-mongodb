import BSONEncoding

extension Mongo
{
    /// Drops the current database, deleting its contents.
    ///
    /// > See:  https://docs.mongodb.com/manual/reference/command/dropDatabase
    public
    struct DropDatabase:Sendable
    {
        public
        let writeConcern:WriteConcern?

        public
        init(writeConcern:WriteConcern? = nil)
        {
            self.writeConcern = writeConcern
        }
    }
}
extension Mongo.DropDatabase:MongoImplicitSessionCommand, MongoCommand
{
    /// The string [`"dropDatabase"`]().
    @inlinable public static
    var name:String
    {
        "dropDatabase"
    }
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = 1 as Int32
        bson["writeConcern"] = self.writeConcern
    }
}
