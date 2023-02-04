import BSONEncoding
import BSONDecoding

@frozen public
struct MongoPredicate:Sendable
{
    public
    var fields:BSON.Fields

    @inlinable public
    init(bytes:[UInt8] = [])
    {
        self.fields = .init(bytes: bytes)
    }
}
extension MongoPredicate:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoPredicate:BSONDecodable
{
}
extension MongoPredicate:BSONEncodable
{
}

extension MongoPredicate
{
    /// @import(BSONDSL)
    /// Encodes an ``Operator``.
    ///
    /// This does not require [`@_disfavoredOverload`](), because
    /// ``Operator`` has no ``String``-keyed subscripts, so it will
    /// never conflict with ``BSON.Fields``.
    @inlinable public
    subscript(key:String) -> Operator?
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
    @inlinable public
    subscript(key:String) -> Self?
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
    @inlinable public
    subscript<Encodable>(key:String) -> Encodable? where Encodable:BSONEncodable
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
extension MongoPredicate
{
    @inlinable public
    subscript(key:Branch) -> BSON.Elements<Self>?
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
    subscript(key:Branch) -> [Self]
    {
        get
        {
            []
        }
        set(value)
        {
            self.fields[pushing: key] = value
        }
    }
    @inlinable public
    subscript<Encodable>(key:Comment) -> Encodable? where Encodable:BSONEncodable
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
    subscript<Encodable>(key:Expr) -> Encodable? where Encodable:MongoExpressionEncodable
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
