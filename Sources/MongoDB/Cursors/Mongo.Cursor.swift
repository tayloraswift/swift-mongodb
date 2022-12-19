import BSONDecoding

extension Mongo
{
    @frozen public
    struct Cursor<Element>:Sendable
        where Element:BSONDocumentDecodable & Sendable
    {
        public
        let namespace:Namespace
        public
        let state:State

        @inlinable public
        init(namespace:Namespace, elements:[Element], next:Mongo.CursorHandle)
        {
            self.namespace = namespace
            self.state = .init(elements: elements, next: next)
        }
    }
}
extension Mongo.Cursor
{
    @inlinable public
    var next:Mongo.CursorHandle
    {
        self.state.next
    }
    @inlinable public
    var batch:[Element]?
    {
        self.state.batch
    }
}
extension Mongo.Cursor
{
    @inlinable public
    var database:Mongo.Database
    {
        self.namespace.database
    }
    @inlinable public
    var collection:Mongo.Collection
    {
        self.namespace.collection
    }
}
extension Mongo.Cursor:Equatable where Element:Equatable
{
}
extension Mongo.Cursor:BSONDictionaryDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.Dictionary<Bytes>) throws
    {
        print(bson.items.keys)
        self = try bson["cursor"].decode(as: BSON.Dictionary<Bytes.SubSequence>.self)
        {
            .init(namespace: try $0["ns"].decode(to: Mongo.Namespace.self),
                elements: try ($0["firstBatch"] ?? $0["nextBatch"]).decode(to: [Element].self),
                next: try $0["id"].decode(to: Mongo.CursorHandle.self))
        }
    }
}
