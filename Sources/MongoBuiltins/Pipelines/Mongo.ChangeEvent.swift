import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct ChangeEvent<Delta> where Delta:MasterCodingDelta, Delta.Model:Identifiable
    {
        public
        let id:ChangeEventIdentifier
        public
        let clusterTime:BSON.Timestamp
        public
        let change:Change<Delta>

        @inlinable public
        init(id:ChangeEventIdentifier,
            clusterTime:BSON.Timestamp,
            change:Change<Delta>)
        {
            self.id = id
            self.clusterTime = clusterTime
            self.change = change
        }
    }
}
extension Mongo.ChangeEvent:Equatable where Mongo.Change<Delta>:Equatable
{
}
extension Mongo.ChangeEvent:Sendable where Mongo.Change<Delta>:Sendable
{
}
extension Mongo.ChangeEvent:BSONDocumentDecodable, BSONDecodable where
    Delta.Model.ID:BSONDecodable,
    Delta.Model:BSONDecodable
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case operationType
        case documentKey
        case fullDocument
        case fullDocumentBeforeChange
        case updateDescription
        case clusterTime
    }

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        let change:Mongo.Change<Delta>

        switch try bson[.operationType].decode(to: Mongo.ChangeOperationType.self)
        {
        case .insert:
            change = .insert(try bson[.fullDocument].decode())

        case .delete:
            change = .delete(.init(.init(), in: try bson[.documentKey].decode()))

        case .update:
            change = .update(.init(try bson[.updateDescription].decode(),
                    in: try bson[.documentKey].decode()),
                before: try bson[.fullDocumentBeforeChange]?.decode(),
                after: try bson[.fullDocument]?.decode())

        case .replace:
            change = .replace(.init(.init(),
                    in: try bson[.documentKey].decode()),
                before: try bson[.fullDocumentBeforeChange]?.decode(),
                after: try bson[.fullDocument].decode())

        default:
            change = ._unimplemented
        }

        self.init(id: try bson[.id].decode(),
            clusterTime: try bson[.clusterTime].decode(),
            change: change)
    }
}
