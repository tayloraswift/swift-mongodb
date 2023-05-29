import MongoWire

extension Mongo
{
    @frozen public
    struct OutlineVector:Sendable
    {
        public
        let documents:OutlineDocuments
        public
        let type:OutlineType

        @inlinable public
        init(_ documents:OutlineDocuments, type:OutlineType)
        {
            self.documents = documents
            self.type = type
        }
    }
}
