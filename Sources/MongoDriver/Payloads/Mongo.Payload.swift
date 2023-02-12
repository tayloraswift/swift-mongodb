import MongoWire

extension Mongo
{
    @frozen public
    struct Payload:Sendable
    {
        public
        let documents:Documents
        public
        let id:ID

        @inlinable public
        init(id:ID, documents:Documents)
        {
            self.documents = documents
            self.id = id
        }
    }
}
extension Mongo.Payload
{
    var outline:MongoWire.Message<[UInt8]>.Outline
    {
        .init(id: self.id.rawValue, slice: self.documents.slice)
    }
}
