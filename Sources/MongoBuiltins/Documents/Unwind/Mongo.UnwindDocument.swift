import BSON
import MongoSchema

extension Mongo
{
    @frozen public
    struct UnwindDocument:MongoDocumentDSL, Sendable
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
extension Mongo.UnwindDocument
{
    @inlinable public
    subscript(key:Field) -> Mongo.KeyPath?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(key, value?.stem)
        }
    }
    @inlinable public
    subscript(key:PreserveNullAndEmptyArrays) -> Bool?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(key, value)
        }
    }
}
