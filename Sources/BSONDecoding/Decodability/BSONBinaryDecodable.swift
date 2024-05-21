/// A type that can be decoded from a BSON binary array.
@available(*, deprecated, message: "Use BSONBinaryDecodable instead")
public
protocol BSONBinaryViewDecodable:BSONDecodable
{
    /// Initializes an instance of this type from the given binary array,
    /// validating the subtype if the conforming type performs type checking.
    init(bson:BSON.BinaryView<ArraySlice<UInt8>>) throws
}
@available(*, deprecated)
extension BSONBinaryViewDecodable
{
    /// Attempts to cast the given variant value to a binary array, and then
    /// delegates to this type’s ``init(bson:) [56R02]`` witness.
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        try self.init(bson: try .init(bson: bson))
    }
}

/// A type that can be decoded from a BSON binary array.
public
protocol BSONBinaryDecodable:BSONDecodable
{
    /// Initializes an instance of this type from the given binary array,
    /// validating the subtype if the conforming type performs type checking.
    init(bson:BSON.BinaryDecoder) throws
}
extension BSONBinaryDecodable
{
    /// Attempts to cast the given variant value to a binary array, and then
    /// delegates to this type’s ``init(bson:) [56R02]`` witness.
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        try self.init(bson: try .init(parsing: bson))
    }
}
