import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct StorageStatsDocument:Sendable
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
extension Mongo.StorageStatsDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.StorageStatsDocument:BSONEncodable
{
}
extension Mongo.StorageStatsDocument:BSONDecodable
{
}

extension Mongo.StorageStatsDocument
{
    @inlinable public
    subscript(key:Scale) -> Int?
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
