import BSONEncoding

extension MongoExpressionDSL
{
    @frozen public
    struct Reduce:Sendable
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
extension MongoExpressionDSL.Reduce:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoExpressionDSL.Reduce:BSONEncodable
{
}
extension MongoExpressionDSL.Reduce
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
            self.fields[key.rawValue] = value
        }
    }
}
