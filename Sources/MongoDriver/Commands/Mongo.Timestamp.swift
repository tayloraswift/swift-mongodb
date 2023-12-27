import BSON

extension Mongo
{
    /// A typed wrapper around a BSON ``UInt64`` value. Unlike
    /// ``UInt64`` itself, this type’s ``BSONDecodable`` and
    /// ``BSONEncodable`` implementations only use the
    /// ``BSON.AnyType/uint64`` data type, and will fail on all other
    /// BSON integer types.
    ///
    /// Despite its name, this is not a true ``InstantProtocol``,
    /// because it does not support measuring or advancing by a
    /// duration. MongoDB timestamps can only be compared for
    /// ordering or equality.
    @frozen public
    struct Timestamp:Hashable, Sendable
    {
        /// The raw BSON timestamp value.
        public
        let value:UInt64

        @inlinable public
        init(_ value:UInt64)
        {
            self.value = value
        }
    }
}
extension Mongo.Timestamp:Mongo.Instant, Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.value < rhs.value
    }
}
extension Mongo.Timestamp:BSONDecodable
{
    /// Attempts to cast a BSON variant backed by some storage type to a
    /// MongoDB timestamp. The conversion is not a integer case, and will
    /// succeed if and only if the variant has type ``BSON.AnyType/uint64``.
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(try bson.cast
        {
            if case .uint64(let value) = $0
            {
                value
            }
            else
            {
                nil
            }
        })
    }
}
extension Mongo.Timestamp:BSONEncodable
{
    /// Encodes this timestamp as a ``BSON.AnyValue/uint64(_:)``.
    @inlinable public
    func encode(to field:inout BSON.FieldEncoder)
    {
        field.encode(uint64: self.value)
    }
}
extension Mongo.Timestamp:CustomStringConvertible
{
    public
    var description:String
    {
        "\(self.value >> 32)+\(self.value & 0x0000_0000_ffff_ffff)"
    }
}
