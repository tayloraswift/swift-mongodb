import BSON

extension Mongo
{
    public
    enum WireSequenceFrame:BSON.BufferFrameType
    {
        @inlinable public static
        var skipped:Int { -4 }
        @inlinable public static
        var trailer:UInt8? { nil }
    }
}
