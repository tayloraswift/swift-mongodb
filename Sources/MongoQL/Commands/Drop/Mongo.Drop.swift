import BSON

extension Mongo
{
    public
    struct Drop:Sendable
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
extension Mongo.Drop:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .drop }
}
extension Mongo.Drop
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
