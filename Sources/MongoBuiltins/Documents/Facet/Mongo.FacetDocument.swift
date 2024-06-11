import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct FacetDocument<CodingKey>:Sendable where CodingKey:RawRepresentable<String>
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
extension Mongo.FacetDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.FacetEncoder<CodingKey>
}
