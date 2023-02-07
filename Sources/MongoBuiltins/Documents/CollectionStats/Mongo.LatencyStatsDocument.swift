import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct LatencyStatsDocument:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension Mongo.LatencyStatsDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
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
            self.fields[pushing: key] = value
        }
    }
}
