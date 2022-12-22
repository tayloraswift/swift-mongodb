import BSON

extension MongoWire.Message
{
    @frozen public
    struct Outline:Identifiable
    {
        public
        let id:String
        public
        var documents:[BSON.Document<Bytes>]

        @inlinable public
        init(id:String, documents:[BSON.Document<Bytes>] = [])
        {
            self.id = id
            self.documents = documents
        }
    }
}
extension MongoWire.Message.Outline:Sendable where Bytes:Sendable
{
}
