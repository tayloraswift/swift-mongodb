import BSONABI
/// A type that can be decoded from a BSON variant value backed by
/// some type of storage not particular to the decoded type.
///
/// This protocol is parallel and unrelated to ``BSON.FrameView`` to
/// emphasize the performance characteristics of types that conform to
/// this protocol and not ``BSON.FrameView``.
public
protocol BSONDecodable
{
    /// Attempts to cast a BSON variant backed by some storage type to an
    /// instance of this type. The implementation can copy the contents
    /// of the backing storage if needed.
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
}

extension BSONDecodable where Self:BSONRepresentable, BSONRepresentation:BSONDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(try .init(bson: bson))
    }
}
extension BSONDecodable where Self:RawRepresentable, RawValue:BSONDecodable & Sendable
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
