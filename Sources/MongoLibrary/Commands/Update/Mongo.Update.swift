import BSONDecoding
import BSONEncoding
import MongoDriver
import NIOCore

extension Mongo
{
    public
    struct Update<Mode>:Sendable where Mode:MongoOverwriteMode
    {
        public
        let writeConcern:WriteConcern?
        public
        let updates:Mongo.Payload.Documents

        public
        var fields:BSON.Document

        private
        init(writeConcern:WriteConcern?,
            updates:Mongo.Payload.Documents,
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

    // TODO: fixme
    public
    typealias Response = Void

    @inlinable public
    var payload:Mongo.Payload?
    {
        .init(id: .updates, documents: self.updates)
    }
}
extension Mongo.Update
{
    @usableFromInline internal
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern?,
        updates:Mongo.Payload.Documents)
    {
        self.init(writeConcern: writeConcern,
            updates: updates,
            fields: Self.type(collection))
    }
}
extension Mongo.Update
{
    @inlinable public
    init(collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        updates statements:some Sequence<Mongo.UpdateStatement<Mode>>)
    {
        var updates:Mongo.Payload.Documents = .init()
        for statement:Mongo.UpdateStatement<Mode> in statements
        {
            updates.append(BSON.DocumentView<[UInt8]>.init(statement.bson))
        }
        self.init(collection: collection, writeConcern: writeConcern,
            updates: updates)
    }
    @inlinable public
    init(collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        updates statements:some Sequence<Mongo.UpdateStatement<Mode>>,
        with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(collection: collection, writeConcern: writeConcern, updates: statements)
        try populate(&self)
    }
}
