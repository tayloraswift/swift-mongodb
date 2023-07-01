import BSONDecoding
import MongoDriver

extension Mongo
{
    public
    struct InsertResponse:Equatable, Sendable
    {
        public
        let writeConcernError:WriteConcernError?
        public
        let writeErrors:[WriteError]
        public
        let inserted:Int

        public
        init(inserted:Int,
            writeConcernError:WriteConcernError? = nil,
            writeErrors:[WriteError] = [])
        {
            self.writeConcernError = writeConcernError
            self.writeErrors = writeErrors
            self.inserted = inserted
        }
    }
}
extension Mongo.InsertResponse
{
    @inlinable public
    var error:any Error
    {
        self.writeConcernError as (any Error)? ??
        self.writeErrors.first as (any Error)? ??
        Mongo.InsertError.init(inserted: self.inserted)
    }
}
extension Mongo.InsertResponse:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(inserted: try bson["n"].decode(),
            writeConcernError: try bson["writeConcernError"]?.decode(),
            writeErrors: try bson["writeErrors"]?.decode() ?? [])
    }
}
