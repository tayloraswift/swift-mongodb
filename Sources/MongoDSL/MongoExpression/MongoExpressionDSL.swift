import BSONEncoding

@frozen public
struct MongoExpressionDSL
{
    public
    var fields:BSON.Fields

    @inlinable public
    init(bytes:[UInt8] = [])
    {
        self.fields = .init(bytes: bytes)
    }
}
extension MongoExpressionDSL:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoExpressionDSL:BSONEncodable
{
}
extension MongoExpressionDSL:MongoExpressionEncodable
{
}
extension BSON.Elements<MongoExpressionDSL>:MongoExpressionEncodable
{
}

extension MongoExpressionDSL?
{
    @_disfavoredOverload
    @inlinable public
    init(with populate:(inout MongoExpressionDSL) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
extension BSON.Elements<MongoExpressionDSL>?
{
    @_disfavoredOverload
    @inlinable public
    init(with populate:(inout BSON.Elements<MongoExpressionDSL>) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
extension MongoExpressionDSL
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
            self.fields[key] = value
        }
    }
}
