extension BSON
{
    /// Specifies the interpretation of a length header attached to a ``BSON.AnyType/document``,
    /// or a ``BSON.AnyType/list`` document.
    @frozen public
    enum DocumentFrame
    {
        case document
        case list
    }
}
extension BSON.DocumentFrame:BSON.BufferFrame
{
    @inlinable public
    var type:BSON.AnyType
    {
        switch self
        {
        case .document: .document
        case .list:     .list
        }
    }

    /// A document always includes a trailing null byte when serialized.
    @inlinable public static
    var trailer:UInt8? { 0x00 }

    /// A document’s length header counts its own length. In other words,
    /// it skips negative 4 bytes.
    @inlinable public static
    var skipped:Int { -4 }
}
