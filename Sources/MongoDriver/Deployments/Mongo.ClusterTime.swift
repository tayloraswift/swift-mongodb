import BSON

extension Mongo
{
    public
    struct ClusterTime:Sendable
    {
        public
        let timestamp:Timestamp
        let signature:BSON.Document

        @usableFromInline
        init(timestamp:Timestamp, signature:BSON.Document)
        {
            self.signature = signature
            self.timestamp = timestamp
        }
    }
}
extension Mongo.ClusterTime:Mongo.Instant
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.timestamp < rhs.timestamp
    }
}
extension Mongo.ClusterTime
{
    @frozen public
    enum CodingKey:String, Sendable
    {
        case clusterTime
        case signature
    }
}
extension Mongo.ClusterTime:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.signature] = self.signature
        bson[.clusterTime] = self.timestamp
    }
}
extension Mongo.ClusterTime:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(timestamp: try bson[.clusterTime].decode(to: Mongo.Timestamp.self),
            signature: try bson[.signature].decode(to: BSON.Document.self))
    }
}
