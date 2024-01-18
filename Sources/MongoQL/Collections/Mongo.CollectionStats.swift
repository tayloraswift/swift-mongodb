import BSON

extension Mongo
{
    @frozen public
    struct CollectionStats:Sendable
    {
        public
        let storage:Storage

        @inlinable public
        init(storage:Storage)
        {
            self.storage = storage
        }
    }
}
extension Mongo.CollectionStats:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case storage = "storageStats"
    }
}
extension Mongo.CollectionStats:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(storage: try bson[.storage].decode())
    }
}
