extension BSON
{
    /// Specifies the interpretation of a length header attached to a ``binary``
    /// array.
    @frozen public
    enum BinaryFrame:FrameType
    {
        /// A binary array header starts its count after skipping the interceding
        /// subtype byte.
        @inlinable public static
        var skipped:Int { 1 }
        /// A binary array never has any trailing bytes when serialized.
        @inlinable public static
        var trailer:UInt8? { nil }
    }
}
