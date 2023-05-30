import BSONDecoding
import MongoDriver

extension Mongo
{
    public
    struct DeleteResponse:Equatable, Sendable
    {
        public
        let writeConcernError:WriteConcernError?
        public
        let writeErrors:[WriteError]

        /// The number of documents deleted by the operation.
        public
        let deleted:Int

        public
        init(deleted:Int,
            writeConcernError:WriteConcernError? = nil,
            writeErrors:[WriteError] = [])
        {
            self.writeConcernError = writeConcernError
            self.writeErrors = writeErrors
            self.deleted = deleted
        }
    }
}
extension Mongo.DeleteResponse:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(deleted: try bson["n"].decode(),
            writeConcernError: try bson["writeConcernError"]?.decode(),
            writeErrors: try bson["writeErrors"]?.decode() ?? [])
    }
}
