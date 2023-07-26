import BSONEncoding
import MongoExpressions
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
    subscript<Encodable>(key:BSON.Key) -> Encodable?
        where Encodable:BSONEncodable
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
