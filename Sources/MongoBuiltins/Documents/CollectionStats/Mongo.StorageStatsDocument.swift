import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct StorageStatsDocument:BSONRepresentable, BSONDSL, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
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
            self.bson.push(key, value)
        }
    }
}
