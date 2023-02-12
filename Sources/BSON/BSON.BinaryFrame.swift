import BSONTraversal

extension BSON
{
    /// Represents a binary array header in the library’s static type system.
    @frozen public
    enum BinaryFrame:VariableLengthBSONFrame
    {
        /// A binary array header starts its count after skipping the interceding
        /// subtype byte. Therefore its conceptual prefix size is -1.
        public static
        let prefix:Int = -1
        public static
        let suffix:Int = 0
    }
}
