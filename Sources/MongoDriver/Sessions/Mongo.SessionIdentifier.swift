import BSONSchema
import BSON_UUID
import UUID

extension Mongo
{
    public 
    struct SessionIdentifier:Hashable, Sendable 
    {
        public
        let uuid:UUID

        @inlinable public
        init(_ uuid:UUID) 
        {
            self.uuid = uuid
        }
    }
}
extension Mongo.SessionIdentifier
{
    static
    func random() -> Self
    {
        .init(.random())
    }
}

extension Mongo.SessionIdentifier:BSONDictionaryDecodable, BSONDocumentEncodable
{
    @inlinable public
    init<Bytes>(bson:BSON.Dictionary<Bytes>) throws
    {
        self.init(try bson["id"].decode(to: UUID.self))
    }
    @inlinable public
    func encode(to bson:inout BSON.Fields)
    {
        bson["id"] = self.uuid
    }
}
