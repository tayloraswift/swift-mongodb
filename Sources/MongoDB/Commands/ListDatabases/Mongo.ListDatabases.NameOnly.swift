import BSONDecoding
import BSONEncoding

extension Mongo.ListDatabases
{
    /// Lists the names of all existing databases. 
    /// This command must run against the `admin` database.
    ///
    /// This command always enables the `nameOnly` option. To disable it, use the
    /// ``ListDatabases`` command.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/listDatabases/
    public
    struct NameOnly:Sendable
    {
        public
        let base:Mongo.ListDatabases

        public
        init(_ base:Mongo.ListDatabases)
        {
            self.base = base
        }
    }
}
extension Mongo.ListDatabases.NameOnly
{
    public
    init(authorizedDatabases:Bool? = nil, filter:BSON.Fields = .init())
    {
        self.init(.init(authorizedDatabases: authorizedDatabases, filter: filter))
    }
}
extension Mongo.ListDatabases.NameOnly:MongoImplicitSessionCommand, MongoCommand
{
    public
    typealias Database = Mongo.Database.Admin
    public
    typealias Response = [Mongo.Database]

    /// The string [`"listDatabases"`]().
    @inlinable public static
    var name:String
    {
        Mongo.ListDatabases.name
    }

    public
    func encode(to bson:inout BSON.Fields)
    {
        self.base.encode(to: &bson)
        bson["nameOnly"] = true
    }

    @inlinable public static
    func decode<Bytes>(reply bson:BSON.Dictionary<Bytes>) throws -> [Mongo.Database]
    {
        try bson["databases"].decode(as: BSON.Array<Bytes.SubSequence>.self)
        {
            try $0.map
            {
                try $0.decode(as: BSON.Dictionary<Bytes.SubSequence>.self)
                {
                    try $0["name"].decode(to: Mongo.Database.self)
                }
            }
        }
    }
}
// FIXME: ListDatabases.NameOnly *can* run on a secondary,
// but *should* run on a primary.
