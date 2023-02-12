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
        var fields:BSON.Fields

        public
        init(authorizedDatabases:Bool? = nil, filter:Mongo.PredicateDocument = [:])
        {
            self.fields = .init
            {
                $0[Self.name] = 1 as Int32
                $0["authorizedDatabases"] = authorizedDatabases
                $0["filter", elide: true] = filter
            }
        }
    }
}
extension Mongo.ListDatabases:MongoImplicitSessionCommand, MongoCommand
{
    /// The string [`"listDatabases"`]().
    @inlinable public static
    var name:String
    {
        "listDatabases"
    }

    public
    typealias Database = Mongo.Database.Admin
    public
    typealias Response =
    (
        totalSize:Int,
        databases:[Mongo.DatabaseMetadata]
    )

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
