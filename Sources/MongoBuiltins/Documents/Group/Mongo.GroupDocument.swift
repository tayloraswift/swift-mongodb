import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct GroupDocument:Sendable
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
extension Mongo.GroupDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.GroupDocument:BSONEncodable
{
}
extension Mongo.GroupDocument:BSONDecodable
{
}

extension Mongo.GroupDocument
{
    @inlinable public
    subscript(key:String) -> Mongo.Accumulator?
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
    @inlinable public
    subscript<Encodable>(key:ID) -> Encodable?
        where Encodable:MongoExpressionEncodable
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
