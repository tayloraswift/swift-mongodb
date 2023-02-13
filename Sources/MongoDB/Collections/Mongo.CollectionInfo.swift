import BSONDecoding
import BSON_UUID
import UUID

extension Mongo
{
    @frozen public
    struct CollectionInfo:Sendable
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
extension Mongo.CollectionInfo:BSONDecodable, BSONDictionaryDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.Dictionary<Bytes>) throws
    {
        self.init(readOnly: try bson["readOnly"].decode(to: Bool.self),
            uuid: try bson["uuid"].decode(to: UUID.self))
    }
}
