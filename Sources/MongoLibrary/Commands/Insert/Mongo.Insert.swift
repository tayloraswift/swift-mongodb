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
        let documents:Mongo.OutlineDocuments

        public
        var fields:BSON.Document

        @usableFromInline internal
        init(writeConcern:WriteConcern?,
            documents:Mongo.OutlineDocuments,
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
    var outline:Mongo.OutlineVector?
    {
        .init(self.documents, type: .documents)
    }
}
extension Mongo.Insert
{
    @inlinable public
    init<Elements>(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        encoding elements:Elements)
        where Elements:Sequence, Elements.Element:BSONDocumentEncodable
    {
        self.init(writeConcern: writeConcern,
            documents: .init(elements),
            fields: Self.type(collection))
    }
    @inlinable public
    init<Elements>(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        encoding elements:Elements,
        with populate:(inout Self) throws -> ()) rethrows
        where Elements:Sequence, Elements.Element:BSONDocumentEncodable
    {
        self.init(collection, writeConcern: writeConcern, encoding: elements)
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
