import BSONEncoding

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
        let documents:Mongo.Payload.Documents?

        public
        var fields:BSON.Fields

        @inlinable public
        init<Elements>(collection:Collection, elements:Elements,
            bypassDocumentValidation:Bool? = nil,
            ordered:Bool? = nil,
            writeConcern:WriteConcern? = nil)
            where Elements:Sequence, Elements.Element:BSONDocumentEncodable
        {
            self.writeConcern = writeConcern
            self.documents = .init(elements)

            self.fields = .init
            {
                $0[Self.name] = collection
                $0["bypassDocumentValidation"] = bypassDocumentValidation
                $0["ordered"] = ordered
            }
        }
    }
}
extension Mongo.Insert:MongoImplicitSessionCommand, MongoTransactableCommand, MongoCommand
{
    /// The string [`"insert"`]().
    @inlinable public static
    var name:String
    {
        "insert"
    }

    public
    typealias Response = Mongo.InsertResponse

    @inlinable public
    var payload:Mongo.Payload?
    {
        self.documents.map { .init(id: .documents, documents: $0) }
    }
}
