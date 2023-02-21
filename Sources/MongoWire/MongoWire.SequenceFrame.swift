import BSONTraversal

extension MongoWire
{
    public
    enum SequenceFrame:VariableLengthBSONFrame
    {
        @inlinable public static
        var skipped:Int { -4 }
        @inlinable public static
        var trailer:UInt8? { nil }
    }
}
