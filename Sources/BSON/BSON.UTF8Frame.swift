import BSONTraversal

extension BSON
{
    @frozen public
    enum UTF8Frame:VariableLengthBSONFrame
    {
        public static
        let prefix:Int = 0
        public static
        let suffix:Int = 1
    }
}
