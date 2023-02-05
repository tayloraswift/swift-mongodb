import BSONEncoding

extension MongoExpression
{
    @frozen public
    struct ReduceDocument:Sendable
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
extension MongoExpression.ReduceDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoExpression.ReduceDocument:BSONEncodable
{
}
extension MongoExpression.ReduceDocument
{
    @inlinable public
    subscript<Encodable>(key:Argument) -> Encodable?
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
}
