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
extension MongoExpressionDSL:MongoExpressionEncodable
{
}

//  These overloads are unique to ``MongoExpressionDSL``, because it has
//  operators that take multiple arguments. The other DSLs don't need these.
extension MongoExpressionDSL?
{
    @_disfavoredOverload
    @inlinable public
    init(with populate:(inout MongoExpressionDSL) throws -> ()) rethrows
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
            self.fields[pushing: key] = value
        }
    }
}
