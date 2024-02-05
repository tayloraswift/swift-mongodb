import BSON

extension Mongo
{
    public
    struct UpdateResponse<ID>:Sendable where ID:BSONDecodable & Sendable
    {
        public
        let writeConcernError:WriteConcernError?
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
        let upserted:[Updates<ID>.Upsertion]

        public
        init(selected:Int,
            modified:Int,
            upserted:[Updates<ID>.Upsertion] = [],
            writeConcernError:WriteConcernError? = nil,
            writeErrors:[WriteError] = [])
        {
            self.writeConcernError = writeConcernError
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
extension Mongo.UpdateResponse
{
    /// Throws a ``WriteConcernError`` if one took place, or the first ``WriteError`` that took
    /// place if no write concern error took place.
    @inlinable public
    func updates() throws -> Mongo.Updates<ID>
    {
        if  let error:any Error =
                self.writeConcernError ??
                self.writeErrors.first
        {
            throw error
        }
        else
        {
            return .init(
                selected: self.selected,
                modified: self.modified,
                upserted: self.upserted)
        }
    }
}
extension Mongo.UpdateResponse:BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key>) throws
    {
        self.init(selected: try bson["n"].decode(),
            modified: try bson["nModified"].decode(),
            upserted: try bson["upserted"]?.decode() ?? [],
            writeConcernError: try bson["writeConcernError"]?.decode(),
            writeErrors: try bson["writeErrors"]?.decode() ?? [])
    }
}
