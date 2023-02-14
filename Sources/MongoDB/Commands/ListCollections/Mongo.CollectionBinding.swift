import BSONDecoding

extension Mongo
{
    @frozen public
    struct CollectionBinding:Sendable
    {
        public
        let collection:Collection
        public
        let type:CollectionType

        @inlinable public
        init(collection:Collection, type:CollectionType)
        {
            self.collection = collection
            self.type = type
        }
    }
}
extension Mongo.CollectionBinding:BSONDecodable, BSONDictionaryDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.Dictionary<Bytes>) throws
    {
        self.init(collection: try bson["name"].decode(to: Mongo.Collection.self),
            type: try bson["type"].decode(to: Mongo.CollectionType.self))
    }
}
