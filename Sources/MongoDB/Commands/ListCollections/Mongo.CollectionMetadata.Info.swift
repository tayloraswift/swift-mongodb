import BSONDecoding
import BSON_UUID
import UUID

extension Mongo.CollectionMetadata
{
    @frozen public
    struct Info:Sendable
    {
        public
        let readOnly:Bool
        public
        let uuid:UUID

        @inlinable public
        init(readOnly:Bool, uuid:UUID)
        {
            self.readOnly = readOnly
            self.uuid = uuid
        }
    }
}
extension Mongo.CollectionMetadata.Info:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<String, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(readOnly: try bson["readOnly"].decode(to: Bool.self),
            uuid: try bson["uuid"].decode(to: UUID.self))
    }
}
