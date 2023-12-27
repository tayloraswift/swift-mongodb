import BSON

extension Mongo
{
    public
    struct CreateIndexes:Sendable
    {
        public
        let writeConcern:WriteConcern?
        public
        var fields:BSON.Document

        @usableFromInline internal
        init(writeConcern:WriteConcern?, fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.fields = fields
        }
    }
}
extension Mongo.CreateIndexes:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .createIndexes }

    public
    typealias Response = Mongo.CreateIndexesResponse
}

extension Mongo.CreateIndexes
{
    public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        indexes:[Mongo.CreateIndexStatement])
    {
        self.init(writeConcern: writeConcern, fields: Self.type(collection))
        self.fields[BSON.Key.self]["indexes"] = indexes
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:WriteConcern? = nil,
        indexes:[Mongo.CreateIndexStatement],
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection, writeConcern: writeConcern, indexes: indexes)
        try populate(&self)
    }
}
extension Mongo.CreateIndexes
{
    @inlinable public
    subscript(key:CommitQuorum) -> Mongo.WriteConcern.Acknowledgement?
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
