import BSONSchema

extension Mongo
{
    public
    struct NotarizedTime:Sendable
    {
        let signature:BSON.Fields
        let time:Instant

        @usableFromInline
        init(signature:BSON.Fields, time:Instant)
        {
            self.signature = signature
            self.time = time
        }
    }
}
extension Mongo.NotarizedTime:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["signature", elide: false] = self.signature
        bson["clusterTime"] = self.time
    }
}
extension Mongo.NotarizedTime:BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(signature: try bson["signature"].decode(to: BSON.Fields.self),
            time: try bson["clusterTime"].decode(to: Mongo.Instant.self))
    }
}
