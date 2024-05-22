import BSON
import MongoABI

extension Mongo.Change
{
    /// Represents an **unsharded** document update.
    @frozen public
    struct Update:Identifiable
    {
        public
        var updatedFields:Delta?
        public
        var removedFields:[Delta.Model.CodingKey]
        public
        var truncatedArrays:[Mongo.ChangeTruncatedArray<Delta.Model.CodingKey>]
        public
        var id:Delta.Model.ID

        @inlinable public
        init(
            updatedFields:Delta? = nil,
            removedFields:[Delta.Model.CodingKey] = [],
            truncatedArrays:[Mongo.ChangeTruncatedArray<Delta.Model.CodingKey>] = [],
            id:Delta.Model.ID)
        {
            self.updatedFields = updatedFields
            self.removedFields = removedFields
            self.truncatedArrays = truncatedArrays
            self.id = id
        }
    }
}
extension Mongo.Change.Update where Delta.Model.ID:BSONDecodable
{
    @inlinable
    init(_ updateDescription:Mongo.Change<Delta>.UpdateDescription,
        in key:Mongo.IdentityDocument<Delta.Model.ID>)
    {
        self.init(
            updatedFields: updateDescription.updatedFields,
            removedFields: updateDescription.removedFields,
            truncatedArrays: updateDescription.truncatedArrays,
            id: key.id)
    }
}
extension Mongo.Change.Update:Equatable
    where Delta:Equatable, Delta.Model.ID:Equatable, Delta.Model.CodingKey:Equatable
{
}
extension Mongo.Change.Update:Sendable
    where Delta:Sendable, Delta.Model.ID:Sendable, Delta.Model.CodingKey:Sendable
{
}
extension Mongo.Change.Update
{
    @inlinable
    var updateDescription:Mongo.Change<Delta>.UpdateDescription
    {
        .init(
            updatedFields: self.updatedFields,
            removedFields: self.removedFields,
            truncatedArrays: self.truncatedArrays)
    }
}
