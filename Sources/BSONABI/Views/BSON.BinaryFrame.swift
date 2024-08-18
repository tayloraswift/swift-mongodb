extension BSON
{
    /// Specifies the interpretation of a length header attached to a ``BSON.AnyType/binary``
    /// array.
    @frozen public
    enum BinaryFrame
    {
        case binary
    }
}
extension BSON.BinaryFrame:BSON.BufferFrame
{
    @inlinable public
    var type:BSON.AnyType
    {
        switch self
        {
        case .binary: .binary
        }
    }

    /// A binary array never has any trailing bytes when serialized.
    @inlinable public static
    var trailer:UInt8? { nil }

    /// A binary array header starts its count after skipping the interceding
    /// ``BinaryView/subtype`` byte.
    @inlinable public static
    var skipped:Int { 1 }
}
