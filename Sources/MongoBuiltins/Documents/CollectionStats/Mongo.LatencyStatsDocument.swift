import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct LatencyStatsDocument:Sendable
    {
        public
        var document:BSON.Document

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.document = .init(bytes: bytes)
        }
    }
}
extension Mongo.LatencyStatsDocument:BSONStream
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.LatencyStatsDocument:BSONEncodable
{
}
extension Mongo.LatencyStatsDocument:BSONDecodable
{
}

extension Mongo.LatencyStatsDocument
{
    @inlinable public
    subscript(key:Histograms) -> Bool?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document.push(key, value)
        }
    }
}
