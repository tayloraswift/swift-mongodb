import BSONTraversal

extension BSON
{
    @frozen public
    enum DocumentFrame:VariableLengthBSONFrame
    {
        public static
        let prefix:Int = 4
        public static
        let suffix:Int = 1
    }
}
