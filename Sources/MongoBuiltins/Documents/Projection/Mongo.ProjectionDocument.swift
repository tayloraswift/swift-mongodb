import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct ProjectionDocument<CodingKey>:Sendable where CodingKey:RawRepresentable<String>
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
extension Mongo.ProjectionDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.ProjectionEncoder<CodingKey>
}
