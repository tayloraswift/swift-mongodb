import BSON
import MongoDriver
import MongoQL

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

        @usableFromInline internal
        var documents:BSON.Output<[UInt8]>

        public
        var fields:BSON.Document

        @usableFromInline internal
        init(writeConcern:WriteConcern?,
            documents:BSON.Output<[UInt8]>,
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
        .init(bson: self.documents, type: .documents)
    }
}
extension Mongo.Insert
{
    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        documents encode:(inout Mongo.InsertEncoder) throws -> ()) rethrows
    {
        var documents:Mongo.InsertEncoder = .init()
        try encode(&documents)

        self.init(writeConcern: writeConcern,
            documents: documents.move(),
            fields: Self.type(collection))
    }

    @inlinable public
    init(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        with configure:(inout Self) throws -> (),
        documents encode:(inout Mongo.InsertEncoder) throws -> ()) rethrows
    {
        try self.init(collection, writeConcern: writeConcern, documents: encode)
        try configure(&self)
    }

    @inlinable public
    init<Elements>(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        encoding elements:Elements)
        where Elements:Sequence, Elements.Element:BSONDocumentEncodable
    {
        self.init(collection, writeConcern: writeConcern) { $0 += elements }
    }

    @inlinable public
    init<Elements>(_ collection:Mongo.Collection,
        writeConcern:Mongo.WriteConcern? = nil,
        encoding elements:Elements,
        with configure:(inout Self) throws -> ()) rethrows
        where Elements:Sequence, Elements.Element:BSONDocumentEncodable
    {
        self.init(collection, writeConcern: writeConcern, encoding: elements)
        try configure(&self)
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
            value?.encode(to: &self.fields[with: key])
        }
    }
}
