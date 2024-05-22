import BSON
import MongoABI

extension Mongo.Change
{
    /// You probably do not want to use this type directly; use ``Update`` instead.
    @frozen @usableFromInline
    struct UpdateDescription
    {
        @usableFromInline
        var updatedFields:Delta?
        @usableFromInline
        var removedFields:[Delta.Model.CodingKey]
        @usableFromInline
        var truncatedArrays:[Mongo.ChangeTruncatedArray<Delta.Model.CodingKey>]

        @inlinable
        init(updatedFields:Delta? = nil,
            removedFields:[Delta.Model.CodingKey] = [],
            truncatedArrays:[Mongo.ChangeTruncatedArray<Delta.Model.CodingKey>] = [])
        {
            self.updatedFields = updatedFields
            self.removedFields = removedFields
            self.truncatedArrays = truncatedArrays
        }
    }
}
extension Mongo.Change.UpdateDescription:Sendable
    where Delta:Sendable, Delta.Model.CodingKey:Sendable
{
}
extension Mongo.Change.UpdateDescription:BSONDecodable, BSONDocumentDecodable
{
    @frozen @usableFromInline
    enum CodingKey:String, Hashable, Sendable
    {
        case updatedFields
        case removedFields
        case truncatedArrays
        case disambiguatedPaths
    }

    @inlinable
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let _:Mongo.EmptyDocument? = try bson[.disambiguatedPaths]?.decode()

        self.init(
            updatedFields: try bson[.updatedFields]?.decode(),
            removedFields: try bson[.removedFields]?.decode() ?? [],
            truncatedArrays: try bson[.truncatedArrays]?.decode() ?? [])
    }
}
