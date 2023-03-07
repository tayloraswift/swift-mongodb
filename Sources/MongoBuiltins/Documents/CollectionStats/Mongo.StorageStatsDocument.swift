import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct StorageStatsDocument:Sendable
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
extension Mongo.StorageStatsDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
            self.document.push(key, value)
        }
    }
}
