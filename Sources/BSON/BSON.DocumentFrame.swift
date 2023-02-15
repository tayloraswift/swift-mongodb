import BSONTraversal

extension BSON
{
    /// Specifies the interpretation of a length header attached to a ``document``,
    /// or a ``list`` document.
    @frozen public
    enum DocumentFrame:VariableLengthBSONFrame
    {
        /// A document’s length header counts its own length. Therefore its
        /// conceptual prefix size is 4.
        public static
        let prefix:Int = 4
        /// A document always includes a trailing null byte when serialized.
        public static
        let suffix:Int = 1
    }
}
