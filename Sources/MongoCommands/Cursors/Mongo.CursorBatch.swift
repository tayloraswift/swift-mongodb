import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct CursorBatch<Element>:Sendable where Element:BSONDecodable & Sendable
    {
        public
        let namespace:Mongo.Namespaced<Mongo.Collection>
        public
        let elements:[Element]
        public
        let position:Int64

        @inlinable public
        init(namespace:Mongo.Namespaced<Mongo.Collection>,
            elements:[Element],
            position:Int64)
        {
            self.namespace = namespace
            self.elements = elements
            self.position = position
        }
    }
}
extension Mongo.CursorBatch:Equatable where Element:Equatable
{
}
extension Mongo.CursorBatch
{
    @inlinable public
    var id:Mongo.CursorIdentifier?
    {
        .init(rawValue: self.position)
    }
}
extension Mongo.CursorBatch:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<BSON.Key>) throws
    {
        self = try bson["cursor"].decode()
        {
            .init(namespace: try $0["ns"].decode(to: Mongo.Namespaced<Mongo.Collection>.self),
                elements: try ($0["firstBatch"] ?? $0["nextBatch"]).decode(to: [Element].self),
                position: try $0["id"].decode(to: Int64.self))
        }
    }
}
