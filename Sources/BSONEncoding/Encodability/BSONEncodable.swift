/// A type that can be encoded to a BSON variant value.
public
protocol BSONEncodable
{
    func encode(to field:inout BSON.Field)
}

extension BSONEncodable where Self:BinaryFloatingPoint
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(double: .init(self))
    }
}

extension Double:BSONEncodable {}

extension UInt64:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.uint64``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(uint64: self)
    }
}
extension UInt:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.uint64``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(uint64: .init(self))
    }
}

extension Int32:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.int32``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(int32: self)
    }
}
extension Int64:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.int64``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(int64: self)
    }
}
extension Int:BSONEncodable
{
    /// Encodes this integer as a value of type ``BSON.int64``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(int64: .init(self))
    }
}

extension Bool:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(bool: self)
    }
}
extension BSON.Decimal128:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(decimal128: self)
    }
}
extension BSON.Identifier:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(id: self)
    }
}
extension BSON.Max:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(max: self)
    }
}
extension BSON.Millisecond:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(millisecond: self)
    }
}
extension BSON.Min:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(min: self)
    }
}
extension BSON.Regex:BSONEncodable
{
    /// Encodes this regex as a value of type ``BSON.regex``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(regex: self)
    }
}
extension String:BSONEncodable
{
    /// Encodes this string as a value of type ``BSON.string``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(string: BSON.UTF8<String.UTF8View>.init(self))
    }
}
extension Optional:BSONEncodable where Wrapped:BSONEncodable
{
    /// Encodes this optional as an explicit ``BSON.null``, if
    /// [`nil`]().
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        if let self:Wrapped
        {
            self.encode(to: &field)
        }
        else
        {
            field.encode(null: ())
        }
    }
}

extension BSONEncodable where Self:RawRepresentable, RawValue:BSONEncodable
{
    /// Returns the ``bson`` witness of this type’s ``RawRepresentable.rawValue``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.rawValue.encode(to: &field)
    }
}

extension BSONEncodable where Self:Sequence, Element:BSONEncodable
{
    /// Encodes this sequence as a value of type ``BSON.tuple``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(tuple: .init(.init(self)))
    }
}
extension Array:BSONEncodable where Element:BSONEncodable
{
}
extension Set:BSONEncodable where Element:BSONEncodable
{
}


extension BSON.Binary:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(binary: self)
    }
}
extension BSON.Document:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: self)
    }
}
extension BSON.Tuple:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(tuple: self)
    }
}
extension BSON.UTF8:BSONEncodable
{
    /// Encodes this UTF-8 string as a ``BSON.string``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(string: self)
    }
}
extension BSON.Fields:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: .init(self))
    }
}
