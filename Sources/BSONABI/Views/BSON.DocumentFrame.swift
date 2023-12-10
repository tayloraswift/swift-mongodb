extension BSON
{
    /// Specifies the interpretation of a length header attached to a ``BSON.AnyType/document``,
    /// or a ``BSON.AnyType/list`` document.
    @frozen public
    enum DocumentFrame:FrameType
    {
        /// A document’s length header counts its own length. In other words,
        /// it skips -4 bytes.
        @inlinable public static
        var skipped:Int { -4 }
        /// A document always includes a trailing null byte when serialized.
        @inlinable public static
        var trailer:UInt8? { 0x00 }
    }
}
