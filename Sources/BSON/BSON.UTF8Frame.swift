import BSONTraversal

extension BSON
{
    /// Specifies the interpretation of a length header attached to UTF-8 ``string``.
    @frozen public
    enum UTF8Frame:VariableLengthBSONFrame
    {
        /// A UTF-8 string’s length header does not count its own length.
        public static
        let prefix:Int = 0
        /// A UTF-8 string always includes a trailing null byte when serialized.
        public static
        let suffix:Int = 1
    }
}
