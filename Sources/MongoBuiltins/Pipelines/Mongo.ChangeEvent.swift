import BSON

extension Mongo
{
    @frozen public
    struct ChangeEvent<Document, DocumentUpdate>:Sendable
        where Document:Sendable, DocumentUpdate:Sendable
    {
        public
        let id:ChangeEventIdentifier
        public
        let clusterTime:BSON.Timestamp
        public
        let operation:ChangeOperation<Document, DocumentUpdate>

        @inlinable public
        init(id:ChangeEventIdentifier,
            clusterTime:BSON.Timestamp,
            operation:ChangeOperation<Document, DocumentUpdate>)
        {
            self.id = id
            self.clusterTime = clusterTime
            self.operation = operation
        }
    }
}
extension Mongo.ChangeEvent:Equatable where Document:Equatable, DocumentUpdate:Equatable
{
}
extension Mongo.ChangeEvent:BSONDocumentDecodable, BSONDecodable where
    Document:BSONDecodable,
    DocumentUpdate:Mongo.ChangeUpdateRepresentation
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
        let operation:Mongo.ChangeOperation<Document, DocumentUpdate>

        switch try bson[.operationType].decode(to: Mongo.ChangeOperationType.self)
        {
        case .insert:
            operation = .insert(try bson[.fullDocument].decode())

        case .update:
            operation = .update(.init(try bson[.updateDescription].decode(),
                    in: try bson[.documentKey].decode()),
                before: try bson[.fullDocumentBeforeChange]?.decode(),
                after: try bson[.fullDocument]?.decode())

        default:
            operation = ._unimplemented
        }

        self.init(id: try bson[.id].decode(),
            clusterTime: try bson[.clusterTime].decode(),
            operation: operation)
    }
}
