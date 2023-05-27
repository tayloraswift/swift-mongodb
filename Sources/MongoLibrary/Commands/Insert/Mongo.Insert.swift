import BSONEncoding
import MongoDriver

extension Mongo
{
    /// Inserts one or more documents and returns a document containing the
    /// status of all inserts.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/insert/
    public
    struct Insert:Sendable
    {
        public
        let writeConcern:WriteConcern?
        public
        let documents:Mongo.Payload.Documents

        public
        var fields:BSON.Document

        private
        init(writeConcern:WriteConcern?,
            documents:Mongo.Payload.Documents,
            fields:BSON.Document)
        {
            self.writeConcern = writeConcern
            self.documents = documents
            self.fields = fields
        }
    }
}
extension Mongo.Insert:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    @inlinable public static
    var type:Mongo.CommandType { .insert }

    /// `Insert` supports retryable writes.
    public
    typealias ExecutionPolicy = Mongo.Retry

    public
    typealias Response = Mongo.InsertResponse

    @inlinable public
    var payload:Mongo.Payload?
    {
        .init(id: .documents, documents: self.documents)
    }
}
extension Mongo.Insert
{
    @usableFromInline internal
    init(collection:Mongo.Collection,
        writeConcern:WriteConcern?,
        documents:Mongo.Payload.Documents)
    {
        self.init(writeConcern: writeConcern,
            documents: documents,
            fields: Self.type(collection))
    }
}
extension Mongo.Insert
{
    @inlinable public
    init<Elements>(collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        elements:Elements)
        where Elements:Sequence, Elements.Element:BSONDocumentEncodable
    {
        self.init(collection: collection, writeConcern: writeConcern,
            documents: .init(elements))
    }
    @inlinable public
    init<Elements>(collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        elements:Elements,
        with populate:(inout Self) throws -> ()) rethrows
        where Elements:Sequence, Elements.Element:BSONDocumentEncodable
    {
        self.init(collection: collection, writeConcern: writeConcern, elements: elements)
        try populate(&self)
    }
}
extension Mongo.Insert
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
}
