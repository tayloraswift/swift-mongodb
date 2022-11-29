import BSONUnions

/// A type that can be decoded from a BSON binary array.
public
protocol BSONBinaryDecodable:BSONDecodable
{
    /// Initializes an instance of this type from the given binary array,
    /// validating the subtype if the conforming type performs type checking.
    init(bson:BSON.Binary<some RandomAccessCollection<UInt8>>) throws
}
extension BSONBinaryDecodable
{
    /// Attempts to cast the given variant value to a binary array, and then
    /// delegates to this type’s ``init(bson:)`` witness.
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(bson))
    }
}
