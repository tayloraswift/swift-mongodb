import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct LatencyStatsDocument:BSONRepresentable, BSONDSL, Sendable
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
            self.bson.push(key, value)
        }
    }
}
