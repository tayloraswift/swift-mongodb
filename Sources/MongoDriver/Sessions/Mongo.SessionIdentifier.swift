import BSON_UUID
import BSONDecoding
import BSONEncoding
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
extension Mongo.SessionIdentifier
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        //  note: no leading underscore
        case id
    }
}
extension Mongo.SessionIdentifier:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(try bson[.id].decode(to: UUID.self))
    }
}
extension Mongo.SessionIdentifier:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.uuid
    }
}
