import BSON

extension Mongo
{
    @frozen public
    struct UpdateArray:BSONRepresentable, BSONDecodable, BSONEncodable, Sendable
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
extension Mongo.UpdateArray:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.UpdateArrayEncoder
}
