import BSONDecoding
import BSONEncoding

extension Mongo
{
    /// Lists all existing databases along with basic statistics about them. 
    /// This command must run against the `admin` database.
    ///
    /// This command never enables the `nameOnly` option. To enable it, use the
    /// ``ListDatabaseNames`` command.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/listDatabases/
    public
    struct ListDatabases:Sendable
    {
        public
        let authorizedDatabases:Bool?
        public
        let filter:BSON.Fields

        public
        init(authorizedDatabases:Bool? = nil, filter:BSON.Fields = .init())
        {
            self.authorizedDatabases = authorizedDatabases
            self.filter = filter
        }
    }
}
extension Mongo.ListDatabases:MongoImplicitSessionCommand, MongoCommand
{
    public
    typealias Database = Mongo.Database.Admin
    public
    typealias Response =
    (
        totalSize:Int,
        databases:[Mongo.DatabaseMetadata]
    )

    /// The string [`"listDatabases"`]().
    @inlinable public static
    var name:String
    {
        "listDatabases"
    }
    
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = 1 as Int32
        bson["authorizedDatabases"] = self.authorizedDatabases
        bson["filter", elide: true] = self.filter
    }

    @inlinable public static
    func decode(reply bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws ->
    (
        totalSize:Int,
        databases:[Mongo.DatabaseMetadata]
    )
    {
        (
            totalSize: try bson["totalSize"].decode(to: Int.self),
            databases: try bson["databases"].decode(to: [Mongo.DatabaseMetadata].self)
        )
    }
}
// FIXME: ListDatabases *can* run on a secondary,
// but *should* run on a primary.
