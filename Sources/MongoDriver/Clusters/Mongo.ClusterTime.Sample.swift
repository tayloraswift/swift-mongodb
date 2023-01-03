import BSONSchema

extension Mongo.ClusterTime
{
    public
    struct Sample:Sendable
    {
        let signature:BSON.Fields
        let instant:Mongo.Instant

        @usableFromInline
        init(signature:BSON.Fields, instant:Mongo.Instant)
        {
            self.signature = signature
            self.instant = instant
        }
    }
}
extension Mongo.ClusterTime.Sample:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["signature", elide: false] = self.signature
        bson["clusterTime"] = self.instant
    }
}
extension Mongo.ClusterTime.Sample:BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(signature: try bson["signature"].decode(to: BSON.Fields.self),
            instant: try bson["clusterTime"].decode(to: Mongo.Instant.self))
    }
}
