import BSONDecoding
import BSONEncoding
import NIOCore

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
        var fields:BSON.Document

        public
        init()
        {
            self.fields = .init
            {
                $0[Self.name] = 1 as Int32
            }
        }
    }
}
extension Mongo.ListDatabases
{
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
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
    func decode(reply bson:BSON.DocumentDecoder<BSON.UniversalKey, ByteBufferView>) throws ->
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

extension Mongo.ListDatabases
{
    @inlinable public
    subscript(key:AuthorizedDatabases) -> Bool?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields.push(key, value)
        }
    }

    @inlinable public
    subscript(key:Filter) -> Mongo.PredicateDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields.push(key, value)
        }
    }
}
