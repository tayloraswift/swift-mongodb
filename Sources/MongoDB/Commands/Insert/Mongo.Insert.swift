import BSONEncoding
import MongoSchema

extension Mongo
{
    /// Inserts one or more documents and returns a document containing the
    /// status of all inserts.
    ///
    /// > See:  https://www.mongodb.com/docs/manual/reference/command/insert/
    @frozen public
    struct Insert<Elements>:Sendable
        where Elements:Sequence & Sendable, Elements.Element:MongoEncodable
    {
        public
        let collection:Collection
        public
        let elements:Elements

        public
        let bypassDocumentValidation:Bool?
        public
        let ordered:Bool?
        public
        let writeConcern:WriteConcern?

        @inlinable public
        init(collection:Collection, elements:Elements,
            bypassDocumentValidation:Bool? = nil,
            ordered:Bool? = nil,
            writeConcern:WriteConcern? = nil)
        {
            self.collection = collection
            self.elements = elements

            self.bypassDocumentValidation = bypassDocumentValidation
            self.ordered = ordered
            self.writeConcern = writeConcern
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
    func encode(to bson:inout BSON.Fields)
    {
        bson[Self.name] = self.collection
        bson["bypassDocumentValidation"] = self.bypassDocumentValidation
        bson["documents"] = .init(elements: self.elements)
        bson["ordered"] = self.ordered
        bson["writeConcern"] = self.writeConcern
    }

    public
    typealias Response = Mongo.InsertResponse
}
