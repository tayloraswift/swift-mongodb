import BSONDecoding
import BSONEncoding

extension Mongo
{
    public
    struct ClusterTime:Sendable
    {
        let signature:BSON.Document
        let time:Instant

        @usableFromInline
        init(signature:BSON.Document, time:Instant)
        {
            self.signature = signature
            self.time = time
        }
    }
}
extension Mongo.ClusterTime
{
    //  Writing this function in terms of ``AtomicState<Self>`` prevents us
    //  from allocating a new object in the common case where the
    //  max cluster time has not changed.
    func combined(with other:Mongo.AtomicState<Self>?) -> Mongo.AtomicState<Self>
    {
        guard let other:Mongo.AtomicState<Self>
        else
        {
            return .init(self)
        }
        if  other.value.time < self.time
        {
            return .init(self)
        }
        else
        {
            return other
        }
    }
}
extension Mongo.ClusterTime
{
    @frozen public
    enum CodingKeys:String
    {
        case clusterTime
        case signature
    }
}
extension Mongo.ClusterTime:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.signature, elide: false] = self.signature
        bson[.clusterTime] = self.time
    }
}
extension Mongo.ClusterTime:BSONDecodable, BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(signature: try bson[.signature].decode(to: BSON.Document.self),
            time: try bson[.clusterTime].decode(to: Mongo.Instant.self))
    }
}
