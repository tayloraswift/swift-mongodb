import BSON

extension Mongo
{
    public
    struct Delete<Effect>:Sendable where Effect:Mongo.WriteEffect
    {
        public
        let writeConcern:WriteConcern?

        @usableFromInline internal
        var deletes:BSON.Output

        public
        var fields:BSON.Document

        @usableFromInline internal
        init(writeConcern:WriteConcern?,
            deletes:BSON.Output,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.deletes = deletes
            self.fields = fields
        }
    }
}
extension Mongo.Delete:Mongo.Command
{
    @inlinable public static
    var type:Mongo.CommandType { .delete }

    /// `Update` only supports retryable writes in single-write mode.
    public
    typealias ExecutionPolicy = Effect.ExecutionPolicy

    public
    typealias Response = Mongo.DeleteResponse

    @inlinable public
    var outline:Mongo.OutlineVector?
    {
        .init(bson: self.deletes, type: .deletes)
    }
}
extension Mongo.Delete
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        deletes encode:(inout Mongo.DeleteEncoder<Effect>) throws -> ()) rethrows
    {
        var deletes:Mongo.DeleteEncoder<Effect> = .init()
        try encode(&deletes)

        self.init(writeConcern: writeConcern,
            deletes: deletes.move(),
            fields: Self.type(collection))
    }

    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        with configure:(inout Self) throws -> (),
        deletes encode:(inout Mongo.DeleteEncoder<Effect>) throws -> ()) rethrows
    {
        try self.init(collection, writeConcern: writeConcern, deletes: encode)
        try configure(&self)
    }
}
extension Mongo.Delete
{
    @inlinable public
    subscript(key:Ordered) -> Bool?
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
    subscript(key:Let) -> Mongo.LetDocument?
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
