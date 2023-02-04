import BSONEncoding
import BSONDecoding

@frozen public
struct MongoProjection:Sendable
{
    public
    var fields:BSON.Fields

    @inlinable public
    init(bytes:[UInt8] = [])
    {
        self.fields = .init(bytes: bytes)
    }
}
extension MongoProjection:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoProjection:BSONEncodable
{
}
extension MongoProjection:BSONDecodable
{
}
extension MongoProjection
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
