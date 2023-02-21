import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct CollectionStatsDocument:Sendable
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
extension Mongo.CollectionStatsDocument:BSONStream
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
            self.document.push(key, value)
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
            self.document.push(key, value)
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
            self.document.push(key, value)
        }
    }
}
