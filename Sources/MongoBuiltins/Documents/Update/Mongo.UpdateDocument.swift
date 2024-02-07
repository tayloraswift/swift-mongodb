import BSON

extension Mongo
{
    @frozen public
    struct UpdateDocument:Sendable
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
extension Mongo.UpdateDocument:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.UpdateEncoder
}
