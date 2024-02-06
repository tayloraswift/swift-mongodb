import BSON
import MongoABI

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
    subscript<Encodable>(path:Mongo.AnyKeyPath) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path.stem])
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
            value?.encode(to: &self.bson[with: binding.name])
        }
    }
}
