import BSON

extension Mongo
{
    @frozen public
    struct CreateIndexStatement:Sendable
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
extension Mongo.CreateIndexStatement:Mongo.EncodableDocument
{
    public
    typealias Encoder = Mongo.CreateIndexStatementEncoder
}
