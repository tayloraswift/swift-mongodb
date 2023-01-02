import BSONSchema

extension Mongo
{
    public
    struct ClusterTime:Sendable
    {
        let signature:BSON.Fields
        public
        let max:Mongo.Instant

        @usableFromInline
        init(signature:BSON.Fields, max:Mongo.Instant)
        {
            self.signature = signature
            self.max = max
        }
    }
}
extension Mongo.ClusterTime:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["signature", elide: false] = self.signature
        bson["clusterTime"] = self.max
    }
}
extension Mongo.ClusterTime:BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(signature: try bson["signature"].decode(to: BSON.Fields.self),
            max: try bson["clusterTime"].decode(to: Mongo.Instant.self))
    }
}
