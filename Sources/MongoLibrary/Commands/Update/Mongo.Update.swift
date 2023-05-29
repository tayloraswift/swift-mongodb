import BSONDecoding
import BSONEncoding
import MongoDriver
import NIOCore

extension Mongo
{
    public
    struct Update<Mode, ID>:Sendable where Mode:MongoOverwriteMode, ID:BSONDecodable
    {
        public
        let writeConcern:WriteConcern?
        public
        let updates:Mongo.OutlineDocuments

        public
        var fields:BSON.Document

        @usableFromInline internal
        init(writeConcern:WriteConcern?,
            updates:Mongo.OutlineDocuments,
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
    typealias ExecutionPolicy = Mode.ExecutionPolicy

    public
    typealias Response = Mongo.UpdateResponse<ID>

    @inlinable public
    var outline:Mongo.OutlineVector?
    {
        .init(self.updates, type: .updates)
    }
}
extension Mongo.Update
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        updates statements:some Sequence<Mongo.UpdateStatement<Mode>>)
    {
        self.init(writeConcern: writeConcern,
            updates: .init(statements),
            fields: Self.type(collection))
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        updates statements:some Sequence<Mongo.UpdateStatement<Mode>>,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection,
            writeConcern: writeConcern,
            updates: statements)
        try populate(&self)
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
            self.fields.push(key, value)
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
            self.fields.push(key, value)
        }
    }
}
