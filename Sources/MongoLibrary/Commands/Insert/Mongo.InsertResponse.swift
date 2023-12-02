import BSON
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
    /// Throws a ``WriteConcernError`` if one took place, or the first ``WriteError`` that took
    /// place if no write concern error took place.
    @inlinable public
    func insertions() throws -> Mongo.Insertions
    {
        if  let error:any Error =
                self.writeConcernError ??
                self.writeErrors.first
        {
            throw error
        }
        else
        {
            return .init(inserted: self.inserted)
        }
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
