import BSON
import MongoDriver
import MongoQL

extension Mongo
{
    public
    struct RenameCollection:Sendable
    {
        public
        let writeConcern:WriteConcern?

        public
        var fields:BSON.Document

        @usableFromInline internal
        init(writeConcern:WriteConcern?,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.fields = fields
        }
    }
}
extension Mongo.RenameCollection:MongoImplicitSessionCommand, MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .renameCollection }

    public
    typealias Database = Mongo.Database.Admin
}
extension Mongo.RenameCollection
{
    public
    init(_ old:Mongo.Namespaced<Mongo.Collection>,
        to new:Mongo.Namespaced<Mongo.Collection>,
        writeConcern:WriteConcern? = nil)
    {
        self.init(writeConcern: writeConcern, fields: Self.type(old)
        {
            $0["to"] = new
        })
    }
    @inlinable public
    init(_ old:Mongo.Namespaced<Mongo.Collection>,
        to new:Mongo.Namespaced<Mongo.Collection>,
        writeConcern:WriteConcern? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(old, to: new, writeConcern: writeConcern)
        try populate(&self)
    }
}
extension Mongo.RenameCollection
{
    @inlinable public
    subscript(key:DropTarget) -> Bool?
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
