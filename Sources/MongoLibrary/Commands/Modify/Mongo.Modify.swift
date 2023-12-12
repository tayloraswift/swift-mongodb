import BSON
import MongoDriver
import MongoQL

extension Mongo
{
    /// Modifies collection settings.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/collMod
    public
    struct Modify<Mode>:Sendable
    {
        public
        let writeConcern:WriteConcern?

        public
        var fields:BSON.Document

        private
        init(writeConcern:WriteConcern?,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.fields = fields
        }
    }
}
extension Mongo.Modify:MongoImplicitSessionCommand, MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .modifyCollection }
}
extension Mongo.Modify
{
    public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil)
    {
        self.init(writeConcern: writeConcern, fields: Self.type(collection))
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection, writeConcern: writeConcern)
        try populate(&self)
    }
}
extension Mongo.Modify<Mongo.Collection>
{
    @inlinable public
    subscript(key:Cap) -> Int?
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
