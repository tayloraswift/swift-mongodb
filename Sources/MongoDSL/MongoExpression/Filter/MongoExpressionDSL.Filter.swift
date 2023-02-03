import BSONEncoding

extension MongoExpressionDSL
{
    @frozen public
    struct Filter:Sendable
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
extension MongoExpressionDSL.Filter:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoExpressionDSL.Filter:BSONEncodable
{
}
extension MongoExpressionDSL.Filter
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
    @inlinable public
    subscript<Encodable>(key:For) -> Encodable?
        where Encodable:MongoExpressionEncodable & BSONStringEncodable
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
