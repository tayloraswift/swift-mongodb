extension BSON
{
    /// Specifies the interpretation of a length header attached to UTF-8 ``string``.
    @frozen public
    enum UTF8Frame:FrameType
    {
        /// A UTF-8 string’s length header does not count its own length.
        @inlinable public static
        var skipped:Int { 0 }
        /// A UTF-8 string always includes a trailing null byte when serialized.
        @inlinable public static
        var trailer:UInt8? { 0x00 }
    }
}
