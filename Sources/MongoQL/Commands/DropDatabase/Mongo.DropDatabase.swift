import BSON

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
extension Mongo.DropDatabase:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .dropDatabase }

    public
    var fields:BSON.Document
    {
        Self.type(nil)
    }
}
