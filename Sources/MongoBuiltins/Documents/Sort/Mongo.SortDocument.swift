import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct SortDocument<CodingKey>:Sendable where CodingKey:RawRepresentable<String>
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
extension Mongo.SortDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.SortEncoder<CodingKey>
}
