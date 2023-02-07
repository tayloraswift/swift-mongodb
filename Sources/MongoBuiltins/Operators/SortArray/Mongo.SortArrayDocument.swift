import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct SortArrayDocument:Sendable
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
extension Mongo.SortArrayDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.SortArrayDocument:BSONDecodable
{
}
extension Mongo.SortArrayDocument:BSONEncodable
{
}
extension Mongo.SortArrayDocument
{
    @inlinable public
    subscript<Encodable>(key:Mongo.SortDocument.Input) -> Encodable?
        where Encodable:MongoExpressionEncodable
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
    @inlinable public
    subscript(key:Mongo.SortDocument.By) -> Mongo.SortDocument?
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
