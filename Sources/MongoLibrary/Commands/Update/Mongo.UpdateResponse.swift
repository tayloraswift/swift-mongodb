import BSONDecoding
import MongoDriver

extension Mongo
{
    public
    struct UpdateResponse<ID> where ID:BSONDecodable
    {
        public
        let writeConcernErrors:[WriteConcernError]
        public
        let writeErrors:[WriteError]

        /// The number of documents selected for the operation. This may be more
        /// than the number of documents ultimately ``modified``.
        public
        let selected:Int
        /// The number of documents modified during the operation. This may be
        /// less than the number of documents ``selected``.
        public
        let modified:Int
        public
        let upserted:[Upsertion]

        public
        init(selected:Int,
            modified:Int,
            upserted:[Upsertion] = [],
            writeConcernErrors:[WriteConcernError] = [],
            writeErrors:[WriteError] = [])
        {
            self.writeConcernErrors = writeConcernErrors
            self.writeErrors = writeErrors
            self.selected = selected
            self.modified = modified
            self.upserted = upserted
        }
    }
}
extension Mongo.UpdateResponse:Equatable where ID:Equatable
{
}
extension Mongo.UpdateResponse:Sendable where ID:Sendable
{
}
extension Mongo.UpdateResponse:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(selected: try bson["n"].decode(),
            modified: try bson["nModified"].decode(),
            upserted: try bson["upserted"]?.decode() ?? [],
            writeConcernErrors: try bson["writeConcernErrors"]?.decode() ?? [],
            writeErrors: try bson["writeErrors"]?.decode() ?? [])
    }
}
