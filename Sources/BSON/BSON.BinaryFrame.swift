import BSONTraversal

extension BSON
{
    /// Specifies the interpretation of a length header attached to a ``binary``
    /// array.
    @frozen public
    enum BinaryFrame:VariableLengthBSONFrame
    {
        /// A binary array header starts its count after skipping the interceding
        /// subtype byte. Therefore its conceptual prefix size is -1.
        public static
        let prefix:Int = -1
        /// A binary array never has any trailing bytes when serialized.
        public static
        let suffix:Int = 0
    }
}
