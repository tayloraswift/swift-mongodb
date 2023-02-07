import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct CollectionStatsDocument:Sendable
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
extension Mongo.CollectionStatsDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.CollectionStatsDocument:BSONEncodable
{
}
extension Mongo.CollectionStatsDocument:BSONDecodable
{
}

extension Mongo.CollectionStatsDocument
{
    @inlinable public
    subscript(key:Keyword) -> [String: Never]?
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
    @inlinable public
    subscript(key:LatencyStats) -> Mongo.LatencyStatsDocument?
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
    @inlinable public
    subscript(key:StorageStats) -> Mongo.StorageStatsDocument?
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
