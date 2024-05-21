import BSON

extension Mongo
{
    @frozen public
    struct Expression:BSONRepresentable, BSONDecodable, BSONEncodable, Sendable
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
