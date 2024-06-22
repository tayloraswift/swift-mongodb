import BSON

extension Mongo
{
    @frozen public
    struct SetDocument<CodingKey>:Sendable where CodingKey:RawRepresentable<String>
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
extension Mongo.SetDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.SetEncoder<CodingKey>
}
