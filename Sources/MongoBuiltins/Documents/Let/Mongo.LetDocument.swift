import BSON
import MongoSchema

extension Mongo
{
    @frozen public
    struct LetDocument:MongoDocumentDSL, Sendable
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
extension Mongo.LetDocument
{
    @inlinable public
    subscript<Encodable>(path:Mongo.KeyPath) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
    @inlinable public
    subscript<Encodable>(`let` binding:Mongo.Variable<some Any>) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(binding.name, value)
        }
    }
}
