import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct UpdateFields<Operator>:Sendable
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
extension Mongo.UpdateFields:MongoDocumentDSL
{
    public
    typealias Encoder = Mongo.UpdateFieldsEncoder<Operator>
}
