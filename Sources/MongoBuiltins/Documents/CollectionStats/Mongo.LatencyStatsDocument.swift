import BSON

extension Mongo
{
    @frozen public
    struct LatencyStatsDocument:Mongo.EncodableDocument, Sendable
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
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.LatencyStatsDocument:ExpressibleByDictionaryLiteral
{
}
