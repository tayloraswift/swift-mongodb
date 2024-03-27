import BSON
import MongoABI

extension Mongo
{
    /// You probably do not want to use this type directly; use ``ChangeUpdate`` instead.
    @frozen public
    struct ChangeUpdateDescription<DocumentDelta> where DocumentDelta:MasterCodingDelta
    {
        public
        var updatedFields:DocumentDelta?
        public
        var removedFields:[DocumentDelta.CodingKey]
        public
        var truncatedArrays:[ChangeTruncatedArray<DocumentDelta.CodingKey>]

        @inlinable public
        init(updatedFields:DocumentDelta?,
            removedFields:[DocumentDelta.CodingKey],
            truncatedArrays:[ChangeTruncatedArray<DocumentDelta.CodingKey>])
        {
            self.updatedFields = updatedFields
            self.removedFields = removedFields
            self.truncatedArrays = truncatedArrays
        }
    }
}
extension Mongo.ChangeUpdateDescription:Sendable
    where DocumentDelta:Sendable, DocumentDelta.CodingKey:Sendable
{
}
extension Mongo.ChangeUpdateDescription:BSONDecodable, BSONDocumentDecodable
{
    @frozen public
    enum CodingKey:String, Hashable, Sendable
    {
        case updatedFields
        case removedFields
        case truncatedArrays
        case disambiguatedPaths
    }

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let _:Mongo.EmptyDocument? = try bson[.disambiguatedPaths]?.decode()

        self.init(
            updatedFields: try bson[.updatedFields]?.decode(),
            removedFields: try bson[.removedFields]?.decode() ?? [],
            truncatedArrays: try bson[.truncatedArrays]?.decode() ?? [])
    }
}
