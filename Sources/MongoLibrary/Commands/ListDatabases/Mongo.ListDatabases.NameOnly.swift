import BSON
import MongoDriver
import MongoQL
import NIOCore

extension Mongo.ListDatabases
{
    /// Retrieves the names of all existing databases.
    ///
    /// This command always enables the `nameOnly` option. Unlike ``ListCollections``’s
    /// name-only mode, `ListDatabases.NameOnly` behaves differently enough from
    /// ``ListDatabases`` that the driver models it as an independent type.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/listDatabases/
    public
    struct NameOnly:Sendable
    {
        public
        var fields:BSON.Document

        public
        init()
        {
            self.fields = Self.type(1 as Int32)
            {
                $0["nameOnly"] = true
            }
        }
    }
}
extension Mongo.ListDatabases.NameOnly
{
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }
}
extension Mongo.ListDatabases.NameOnly:MongoImplicitSessionCommand, MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .listDatabases }

    /// `ListDatabases` supports retryable reads.
    public
    typealias ExecutionPolicy = Mongo.ListDatabases.ExecutionPolicy

    /// ``ListDatabases`` must be run against the `admin` database.
    public
    typealias Database = Mongo.ListDatabases.Database

    public
    typealias Response = [Mongo.Database]

    @inlinable public static
    func decode(
        reply bson:BSON.DocumentDecoder<BSON.Key, ByteBufferView>) throws -> [Mongo.Database]
    {
        try bson["databases"].decode
        {
            try $0.map
            {
                try $0.decode
                {
                    try $0["name"].decode(to: Mongo.Database.self)
                }
            }
        }
    }
}
// FIXME: ListDatabases.NameOnly *can* run on a secondary,
// but *should* run on a primary.
extension Mongo.ListDatabases.NameOnly
{
    @inlinable public
    subscript(key:Mongo.ListDatabases.AuthorizedDatabases) -> Bool?
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
    subscript(key:Mongo.ListDatabases.Filter) -> Mongo.PredicateDocument?
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
