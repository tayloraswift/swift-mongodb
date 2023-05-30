import BSONDecoding
import BSONEncoding
import MongoDriver
import NIOCore

extension Mongo
{
    public
    struct Delete<Plurality>:Sendable where Plurality:MongoWriteEffect
    {
        public
        let writeConcern:WriteConcern?
        public
        let deletes:Mongo.OutlineDocuments

        public
        var fields:BSON.Document

        @usableFromInline internal
        init(writeConcern:WriteConcern?,
            deletes:Mongo.OutlineDocuments,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.deletes = deletes
            self.fields = fields
        }
    }
}
extension Mongo.Delete:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .delete }

    /// `Update` only supports retryable writes in single-write mode.
    public
    typealias ExecutionPolicy = Plurality.ExecutionPolicy

    public
    typealias Response = Mongo.DeleteResponse

    @inlinable public
    var outline:Mongo.OutlineVector?
    {
        .init(self.deletes, type: .deletes)
    }
}
extension Mongo.Delete
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        deletes statements:some Sequence<Mongo.DeleteStatement<Plurality>>)
    {
        self.init(writeConcern: writeConcern,
            deletes: .init(statements),
            fields: Self.type(collection))
    }
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        deletes statements:some Sequence<Mongo.DeleteStatement<Plurality>>,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection,
            writeConcern: writeConcern,
            deletes: statements)
        try populate(&self)
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
