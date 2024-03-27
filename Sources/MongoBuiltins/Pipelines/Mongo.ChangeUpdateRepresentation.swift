import BSON
import MongoABI

extension Mongo
{
    public
    protocol ChangeUpdateRepresentation<DocumentDelta, DocumentKey>
    {
        associatedtype DocumentDelta:BSONDecodable, MasterCodingDelta
        associatedtype DocumentKey:BSONDecodable

        init(_:ChangeUpdateDescription<DocumentDelta>, in:DocumentKey)
    }
}
