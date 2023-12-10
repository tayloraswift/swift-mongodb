import BSON
import MongoABI

extension Mongo.Cursor
{
    @frozen public
    struct Batch:Sendable
    {
        public
        let namespace:Mongo.Namespaced<Mongo.Collection>
        public
        let elements:[BatchElement]
        public
        let position:Int64

        @inlinable public
        init(namespace:Mongo.Namespaced<Mongo.Collection>,
            elements:[BatchElement],
            position:Int64)
        {
            self.namespace = namespace
            self.elements = elements
            self.position = position
        }
    }
}
extension Mongo.Cursor.Batch:Equatable where BatchElement:Equatable
{
}
extension Mongo.Cursor.Batch
{
    @inlinable public
    var id:Mongo.CursorIdentifier?
    {
        .init(rawValue: self.position)
    }
}
extension Mongo.Cursor.Batch:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<BSON.Key, Bytes>) throws
    {
        self = try bson["cursor"].decode()
        {
            .init(namespace: try $0["ns"].decode(to: Mongo.Namespaced<Mongo.Collection>.self),
                elements: try ($0["firstBatch"] ?? $0["nextBatch"]).decode(
                    to: [BatchElement].self),
                position: try $0["id"].decode(to: Int64.self))
        }
    }
}
