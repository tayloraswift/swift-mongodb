import BSONABI

/// A type that can be encoded to a BSON variant value.
public
protocol BSONEncodable
{
    func encode(to field:inout BSON.FieldEncoder)
}
extension BSONEncodable where Self:BSONRepresentable, BSONRepresentation:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.bson.encode(to: &field)
    }
}
extension BSONEncodable where Self:RawRepresentable, RawValue:BSONEncodable
{
    /// Returns the ``encode(to:) [7NT06]`` witness of this type’s
    /// ``RawRepresentable/rawValue``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        self.rawValue.encode(to: &field)
    }
}

@available(*, unavailable, message: "Currently useless due to a compiler bug!")
extension BSONEncodable where Self == BSON.Min
{
    /// A shorthand for encoding a ``BSON.Min`` value.
    @inlinable public static
    var min:Self { .init() }
}
@available(*, unavailable, message: "Currently useless due to a compiler bug!")
extension BSONEncodable where Self == BSON.Max
{
    /// A shorthand for encoding a ``BSON.Max`` value.
    @inlinable public static
    var max:Self { .init() }
}
@available(*, unavailable, message: "Currently useless due to a compiler bug!")
extension BSONEncodable where Self == BSON.Null
{
    /// A shorthand for encoding an explicit ``BSON.Null`` value.
    @inlinable public static
    var null:Self { .init() }
}


@available(*, deprecated,
    message: "UInt64 is not recommended for BSON that will be handled by MongoDB.")
extension UInt64:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.AnyType/uint64``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(timestamp: .init(self))
    }
}
@available(*, deprecated,
    message: "UInt is not recommended for BSON that will be handled by MongoDB.")
extension UInt:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.AnyType/uint64``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(timestamp: .init(UInt64.init(self)))
    }
}
