import BSONDecoding

extension Mongo
{
    @frozen public
    struct CollectionMetadata:Sendable
    {
        public
        let collection:Collection
        public
        let options:CollectionOptions
        public
        let info:Info

        @inlinable public
        init(collection:Collection, options:CollectionOptions, info:Info)
        {
            self.collection = collection
            self.options = options
            self.info = info
        }
    }
}
extension Mongo.CollectionMetadata
{
    public
    var type:Mongo.CollectionType
    {
        self.options.variant.type
    }
}
extension Mongo.CollectionMetadata:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init<Bytes>(bson:BSON.DocumentDecoder<BSON.UniversalKey, Bytes>) throws
    {
        self.init(
            collection: try bson["name"].decode(to: Mongo.Collection.self),
            options: try bson["options"].decode(
                as: BSON.DocumentDecoder<BSON.UniversalKey, Bytes.SubSequence>.self)
            {
                try .init(bson: $0, 
                    type: try bson["type"].decode(to: Mongo.CollectionType.self))
            },
            info: try bson["info"].decode(to: Info.self))
    }
}
