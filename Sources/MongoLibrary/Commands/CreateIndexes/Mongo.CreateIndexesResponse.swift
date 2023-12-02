import BSON
import MongoDriver

extension Mongo
{
    public
    struct CreateIndexesResponse:Equatable, Sendable
    {
        public
        let createdCollectionAutomatically:Bool?
        public
        let indexesBefore:Int
        public
        let indexesAfter:Int
        public
        let note:String?

        public
        init(createdCollectionAutomatically:Bool?,
            indexesBefore:Int,
            indexesAfter:Int,
            note:String? = nil)
        {
            self.createdCollectionAutomatically = createdCollectionAutomatically
            self.indexesBefore = indexesBefore
            self.indexesAfter = indexesAfter
            self.note = note
        }
    }
}
extension Mongo.CreateIndexesResponse:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(
            createdCollectionAutomatically:
                try bson["createdCollectionAutomatically"]?.decode(),
            indexesBefore: try bson["numIndexesBefore"].decode(),
            indexesAfter: try bson["numIndexesAfter"].decode(),
            note: try bson["note"]?.decode())
    }
}
