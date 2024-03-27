import BSON
import MongoABI

extension Mongo
{
    /// Represents an **unsharded** document update.
    @frozen public
    struct ChangeUpdate<DocumentDelta, ID> where DocumentDelta:MasterCodingDelta
    {
        public
        var updatedFields:DocumentDelta?
        public
        var removedFields:[DocumentDelta.CodingKey]
        public
        var truncatedArrays:[ChangeTruncatedArray<DocumentDelta.CodingKey>]
        public
        var id:ID

        @inlinable public
        init(
            updatedFields:DocumentDelta? = nil,
            removedFields:[DocumentDelta.CodingKey] = [],
            truncatedArrays:[ChangeTruncatedArray<DocumentDelta.CodingKey>] = [],
            id:ID)
        {
            self.updatedFields = updatedFields
            self.removedFields = removedFields
            self.truncatedArrays = truncatedArrays
            self.id = id
        }
    }
}
extension Mongo.ChangeUpdate:Mongo.ChangeUpdateRepresentation where ID:BSONDecodable
{
    @inlinable public
    init(_ updateDescription:Mongo.ChangeUpdateDescription<DocumentDelta>,
        in key:Mongo.IdentityDocument<ID>)
    {
        self.init(
            updatedFields: updateDescription.updatedFields,
            removedFields: updateDescription.removedFields,
            truncatedArrays: updateDescription.truncatedArrays,
            id: key.id)
    }
}
extension Mongo.ChangeUpdate:Equatable
    where DocumentDelta:Equatable, DocumentDelta.CodingKey:Equatable, ID:Equatable
{
}
extension Mongo.ChangeUpdate:Sendable
    where DocumentDelta:Sendable, DocumentDelta.CodingKey:Sendable, ID:Sendable
{
}
extension Mongo.ChangeUpdate
{
    @inlinable public
    var updateDescription:Mongo.ChangeUpdateDescription<DocumentDelta>
    {
        .init(
            updatedFields: self.updatedFields,
            removedFields: self.removedFields,
            truncatedArrays: self.truncatedArrays)
    }
}
