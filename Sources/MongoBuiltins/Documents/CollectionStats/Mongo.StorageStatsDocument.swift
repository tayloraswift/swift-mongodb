import BSON

extension Mongo
{
    @frozen public
    struct StorageStatsDocument:MongoDocumentDSL, Sendable
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
            value?.encode(to: &self.bson[with: key])
        }
    }
}
