import BSON
import MongoDriver
import MongoQL
import NIOCore

extension Mongo
{
    public
    struct Update<Effect, ID>:Sendable
        where   Effect:MongoWriteEffect,
                ID:BSONDecodable,
                ID:Sendable
    {
        public
        let writeConcern:WriteConcern?

        @usableFromInline internal
        var updates:BSON.Output<[UInt8]>

        public
        var fields:BSON.Document

        @usableFromInline internal
        init(writeConcern:WriteConcern?,
            updates:BSON.Output<[UInt8]>,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.updates = updates
            self.fields = fields
        }
    }
}
extension Mongo.Update:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .update }

    /// `Update` only supports retryable writes in single-write mode.
    public
    typealias ExecutionPolicy = Effect.ExecutionPolicy

    public
    typealias Response = Mongo.UpdateResponse<ID>

    @inlinable public
    var outline:Mongo.OutlineVector?
    {
        .init(bson: self.updates, type: .updates)
    }
}
extension Mongo.Update
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        updates encode:(inout Mongo.UpdateEncoder<Effect>) throws -> ()) rethrows
    {
        var updates:Mongo.UpdateEncoder<Effect> = .init()
        try encode(&updates)

        self.init(writeConcern: writeConcern,
            updates: updates.move(),
            fields: Self.type(collection))
    }

    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        with configure:(inout Self) throws -> (),
        updates encode:(inout Mongo.UpdateEncoder<Effect>) throws -> ()) rethrows
    {
        try self.init(collection, writeConcern: writeConcern, updates: encode)
        try configure(&self)
    }
}
extension Mongo.Update
{
    @inlinable public
    subscript(key:Flag) -> Bool?
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
