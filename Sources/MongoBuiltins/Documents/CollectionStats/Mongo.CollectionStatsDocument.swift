import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct CollectionStatsDocument:MongoDocumentDSL, Sendable
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
        }
    }
}
