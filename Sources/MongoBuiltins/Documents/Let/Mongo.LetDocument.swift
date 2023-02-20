import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct LetDocument:Sendable
    {
        public
        var document:BSON.Document

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.document = .init(bytes: bytes)
        }
    }
}
extension Mongo.LetDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
            self.document.push(key, value)
        }
    }
}
