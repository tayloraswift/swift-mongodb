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
        deletes encode:(inout Mongo.DeleteListEncoder<Effect>) throws -> ()) rethrows
    {
        var deletes:Mongo.DeleteListEncoder<Effect> = .init()
        try encode(&deletes)

        self.init(writeConcern: writeConcern,
            deletes: deletes.move(),
            fields: Self.type(collection))
    }

    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        with configure:(inout Self) throws -> (),
        deletes encode:(inout Mongo.DeleteListEncoder<Effect>) throws -> ()) rethrows
    {
        try self.init(collection, writeConcern: writeConcern, deletes: encode)
        try configure(&self)
    }
}
extension Mongo.Delete
{
    @frozen public
    enum Ordered:String, Equatable, Hashable, Sendable
    {
        case ordered
    }

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
}
extension Mongo.Delete
{
    @frozen public
    enum Let:String, Sendable
    {
        case `let`
    }

    @inlinable public
    subscript(key:Let, yield:(inout Mongo.LetEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.fields[with: key][as: Mongo.LetEncoder.self])
        }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(key:Let) -> Mongo.LetDocument?
    {
        nil
    }
}
