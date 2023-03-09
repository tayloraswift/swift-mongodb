/// A type that can be decoded from a BSON variant value backed by
/// some type of storage not particular to the decoded type.
///
/// This protocol is parallel and unrelated to ``BSONDecodableView`` to
/// emphasize the performance characteristics of types that conform to
/// this protocol and not ``BSONDecodableView``.
public
protocol BSONDecodable
{
    /// Attempts to cast a BSON variant backed by some storage type to an
    /// instance of this type. The implementation can copy the contents
    /// of the backing storage if needed.
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
}

extension Never:BSONDecodable
{
    /// Always throws a ``BSON.TypecastError``.
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        throw BSON.TypecastError<Never>.init(invalid: bson.type)
    }
}
extension Bool:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}
extension BSON.Decimal128:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}
extension BSON.Identifier:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}
extension BSON.Max:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}
extension BSON.Millisecond:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}
extension BSON.Min:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}
extension BSON.Regex:BSONDecodable
{
    /// Attempts to unwrap a ``BSON/Regex`` from the given variant.
    /// The library always eagerly-parses regexes, so this initializer
    /// does not perform any copying.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}

extension UInt8:BSONDecodable {}
extension UInt16:BSONDecodable {}
extension UInt32:BSONDecodable {}
extension UInt64:BSONDecodable {}
extension UInt:BSONDecodable {}

extension Int8:BSONDecodable {}
extension Int16:BSONDecodable {}
extension Int32:BSONDecodable {}
extension Int64:BSONDecodable {}
extension Int:BSONDecodable {}

extension Float:BSONDecodable {}
extension Double:BSONDecodable {}
extension Float80:BSONDecodable {}

extension BSONDecodable where Self:BSONRepresentable, BSONRepresentation:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(try .init(bson: bson))
    }
}
extension BSONDecodable where Self:RawRepresentable, RawValue:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        let rawValue:RawValue = try .init(bson: bson)
        if  let value:Self = .init(rawValue: rawValue)
        {
            self = value
        }
        else 
        {
            throw BSON.ValueError<RawValue, Self>.init(invalid: rawValue)
        }
    }
}
extension BSONDecodable where Self:FixedWidthInteger
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { try $0.as(Self.self) }
    }
}
extension BSONDecodable where Self:BinaryFloatingPoint
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.cast { $0.as(Self.self) }
    }
}

extension Optional:BSONDecodable where Wrapped:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        if case .null = bson 
        {
            self = .none 
        }
        else
        {
            self = .some(try .init(bson: bson))
        }
    }
}
