import BSON
import BSON_OrderedCollections
import OrderedCollections

extension Mongo.CollectionStats
{
    @frozen public
    struct Storage:Sendable
    {
        /// The portion of ``storageSize`` that is available for reuse.
        public
        let storageFree:Int
        /// The total **compressed** size of all the documents in the collection.
        public
        let storageSize:Int
        /// The total **uncompressed** size of all the documents in the collection.
        public
        let logicalSize:Int
        /// The total size of all the collection’s indexes.
        public
        let indexesSize:Int
        /// The individual sizes of each of the collection’s indexes.
        public
        let indexSizes:OrderedDictionary<BSON.Key, Int>
        /// The number of documents in the collection.
        public
        let count:Int

        @inlinable public
        init(storageFree:Int,
            storageSize:Int,
            logicalSize:Int,
            indexesSize:Int,
            indexSizes:OrderedDictionary<BSON.Key, Int>,
            count:Int)
        {
            self.storageFree = storageFree
            self.storageSize = storageSize
            self.logicalSize = logicalSize
            self.indexesSize = indexesSize
            self.indexSizes = indexSizes
            self.count = count
        }
    }
}
extension Mongo.CollectionStats.Storage:MongoMasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable, CaseIterable
    {
        case storageFree = "freeStorageSize"
        case storageSize = "storageSize"
        case logicalSize = "size"
        case indexesSize = "totalIndexSize"
        case indexSizes = "indexSizes"
        case count
    }
}
extension Mongo.CollectionStats.Storage:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            storageFree: try bson[.storageFree]?.decode() ?? 0,
            storageSize: try bson[.storageSize].decode(),
            logicalSize: try bson[.logicalSize].decode(),
            indexesSize: try bson[.indexesSize].decode(),
            indexSizes: try bson[.indexSizes].decode(),
            count: try bson[.count].decode())
    }
}
