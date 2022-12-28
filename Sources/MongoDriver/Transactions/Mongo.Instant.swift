import BSONSchema
import BSONUnions

extension Mongo
{
    /// A typed wrapper around a BSON ``UInt64`` value. Unlike
    /// ``UInt64`` itself, this type’s ``BSONDecodable`` and
    /// ``BSONEncodable`` implementations only use the
    /// ``BSON.uint64`` data type, and will fail on all other
    /// BSON integer types.
    ///
    /// Despite its name, this is not a true ``InstantProtocol``,
    /// because it does not support measuring or advancing by a
    /// duration. MongoDB timestamps can only be compared for
    /// ordering or equality.
    @frozen public
    struct Instant:Hashable, Sendable
    {
        /// The raw BSON timestamp value.
        public
        let timestamp:UInt64

        @inlinable public
        init(timestamp:UInt64)
        {
            self.timestamp = timestamp
        }
    }
}
extension Mongo.Instant:Comparable
{
    @inlinable public static
    func < (lhs:Self, rhs:Self) -> Bool
    {
        lhs.timestamp < rhs.timestamp
    }
}
extension Mongo.Instant:BSONDecodable
{
    /// Attempts to cast a BSON variant backed by some storage type to a
    /// MongoDB timestamp. The conversion is not a integer case, and will
    /// succeed if and only if the variant has type ``BSON.uint64``.
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(timestamp: try bson.cast
        {
            if case .uint64(let timestamp) = $0
            {
                return timestamp
            }
            else
            {
                return nil
            }
        })
    }
}
extension Mongo.Instant:BSONEncodable
{
    /// Encodes this timestamp as a ``BSON.uint64``.
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        field.encode(uint64: self.timestamp)
    }
}
extension Mongo.Instant:CustomStringConvertible
{
    public
    var description:String
    {
        "\(self.timestamp >> 32)+\(self.timestamp & 0x0000_0000_ffff_ffff)"
    }
}
