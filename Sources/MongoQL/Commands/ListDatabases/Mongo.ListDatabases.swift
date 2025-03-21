import BSON

extension Mongo
{
    /// Lists all existing databases along with basic statistics about them.
    /// This command must run against the `admin` database.
    ///
    /// This command never enables the `nameOnly` option. To enable it, use the
    /// ``ListDatabases.NameOnly`` command.
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
            self.fields = Self.type(nil)
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
extension Mongo.ListDatabases:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .listDatabases }

    /// `ListDatabases` supports retryable reads.
    public
    typealias ExecutionPolicy = Mongo.Retry

    public
    typealias Database = Mongo.Database.Admin

    public
    typealias Response =
    (
        totalSize:Int,
        databases:[Mongo.DatabaseMetadata]
    )

    @inlinable public static
    func decode(reply bson:BSON.DocumentDecoder<BSON.Key>) throws ->
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
            value?.encode(to: &self.fields[with: key])
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
            value?.encode(to: &self.fields[with: key])
        }
    }
}
