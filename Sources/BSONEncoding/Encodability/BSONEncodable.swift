/// A type that can be encoded to a BSON variant value.
public
protocol BSONEncodable:BSONFieldEncodable
{
    func encode(to field:inout BSON.Field)
}

extension Optional:BSONEncodable where Wrapped:BSONEncodable
{
}

//  We generally do *not* want dictionaries to be encodable, and dictionary
//  literal generate dictionaries by default.
extension [String: Never]:BSONEncodable
{
}
extension Array:BSONEncodable where Element:BSONEncodable
{
}
extension Set:BSONEncodable where Element:BSONEncodable
{
}

extension Never:BSONEncodable
{
    /// Never encodes anything.
    @inlinable public
    func encode(to _:inout BSON.Field)
    {
    }
}

extension BSON:BSONEncodable
{
    /// Encodes this metatype as a value of type ``BSON.int32``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(int32: .init(self.rawValue))
    }
}

extension Double:BSONEncodable
{
}

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
extension Unicode.Scalar:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.description.encode(to: &field)
    }
}
extension Character:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        self.description.encode(to: &field)
    }
}
//  ``Substring`` and ``String`` are ``Sequence``s of ``Character``s,
//  and if we did not provide concrete implementations, they would
//  be caught between default implementations.
extension Substring:BSONEncodable
{
    /// Encodes this substring as a value of type ``BSON.string``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(string: .init(self))
    }
}
extension String:BSONEncodable
{
    /// Encodes this string as a value of type ``BSON.string``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(string: .init(self))
    }
}
extension StaticString:BSONEncodable
{
    /// Encodes this string as a value of type ``BSON.string``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(string: .init(self))
    }
}

extension BSON.BinaryView:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(binary: self)
    }
}
extension BSON.DocumentView:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(document: self)
    }
}
extension BSON.ListView:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(list: self)
    }
}
extension BSON.UTF8View:BSONEncodable
{
    /// Encodes this UTF-8 string as a ``BSON.string``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(string: self)
    }
}
