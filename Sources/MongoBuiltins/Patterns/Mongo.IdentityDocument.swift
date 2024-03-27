import BSON
import MongoABI

extension Mongo
{
    /// An generic document model that can be used to extract the `_id` field of a document.
    /// This type is suitable for unsharded collections only.
    @frozen public
    struct IdentityDocument<ID>
    {
        public
        let id:ID

        @inlinable public
        init(id:ID)
        {
            self.id = id
        }
    }
}
extension Mongo.IdentityDocument:Identifiable where ID:Hashable
{
}
extension Mongo.IdentityDocument:Sendable where ID:Sendable
{
}
extension Mongo.IdentityDocument:Mongo.MasterCodingModel
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
    }
}
extension Mongo.IdentityDocument:BSONDecodable, BSONDocumentDecodable where ID:BSONDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode())
    }
}
