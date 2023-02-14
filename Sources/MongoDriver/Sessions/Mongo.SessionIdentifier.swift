import BSONDecoding
import BSONEncoding
import BSON_UUID
import UUID

extension Mongo
{
    @frozen public 
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

extension Mongo.SessionIdentifier:BSONDecodable, BSONDictionaryDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.Dictionary<Bytes>) throws
    {
        self.init(try bson["id"].decode(to: UUID.self))
    }
}
extension Mongo.SessionIdentifier:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Document)
    {
        bson["id"] = self.uuid
    }
}
