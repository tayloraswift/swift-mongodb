import BSONDecoding
import MongoDriver

extension Mongo
{
    public
    struct InsertResponse:Equatable, Sendable
    {
        public
        let writeConcernErrors:[WriteConcernError]
        public
        let writeErrors:[WriteError]
        public
        let inserted:Int

        public
        init(inserted:Int,
            writeConcernErrors:[WriteConcernError] = [],
            writeErrors:[WriteError] = [])
        {
            self.writeConcernErrors = writeConcernErrors
            self.writeErrors = writeErrors
            self.inserted = inserted
        }
    }
}
extension Mongo.InsertResponse:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(inserted: try bson["n"].decode(),
            writeConcernErrors: try bson["writeConcernErrors"]?.decode() ?? [],
            writeErrors: try bson["writeErrors"]?.decode() ?? [])
    }
}
