import BSONTraversal

extension Mongo
{
    public
    enum WireSequenceFrame:VariableLengthBSONFrame
    {
        @inlinable public static
        var skipped:Int { -4 }
        @inlinable public static
        var trailer:UInt8? { nil }
    }
}
