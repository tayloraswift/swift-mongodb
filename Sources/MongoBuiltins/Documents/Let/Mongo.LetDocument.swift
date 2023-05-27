import BSONDecoding
import BSONEncoding
import MongoDSL

extension Mongo
{
    @frozen public
    struct LetDocument:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.LetDocument:BSONEncodable
{
}
extension Mongo.LetDocument:BSONDecodable
{
}

extension Mongo.LetDocument
{
    @inlinable public
    subscript<Encodable>(key:String) -> Encodable? where Encodable:MongoExpressionEncodable
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
