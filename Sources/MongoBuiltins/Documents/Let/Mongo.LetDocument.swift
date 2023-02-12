import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct LetDocument:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension Mongo.LetDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
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
            self.fields[pushing: key] = value
        }
    }
}
