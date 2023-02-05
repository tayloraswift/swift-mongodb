import BSONDecoding
import BSONEncoding

extension MongoExpression
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
extension MongoExpression.SortArrayDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoExpression.SortArrayDocument:BSONDecodable
{
}
extension MongoExpression.SortArrayDocument:BSONEncodable
{
}
extension MongoExpression.SortArrayDocument
{
    @inlinable public
    subscript<Encodable>(key:MongoSortOrdering.Input) -> Encodable?
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
    subscript(key:MongoSortOrdering.By) -> MongoSortOrdering?
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
