/// A type that specifies the layout of a variable-length BSON view.
/// Parsers use conforming types to decide how to interpret BSON
/// length headers read from input data.
public
protocol VariableLengthBSONFrame
{
    /// The number of (conceptual) bytes in the frame prefix of the type
    /// this frame type is associated with.
    /// This can be zero if the frame’s length header does not include its
    /// own length, and can be positive if the length header skips additional
    /// bytes before it starts counting.
    static
    var skipped:Int { get }

    /// A trailing byte to append, if any.
    static
    var trailer:UInt8? { get }
}
extension VariableLengthBSONFrame
{
    /// The number of (conceptual) bytes in the frame suffix of the type
    /// this frame type is associated with. This is 0 if ``trailer`` is
    /// nil, and 1 otherwise.
    @inlinable public static
    var suffix:Int
    {
        switch self.trailer
        {
        case nil:   return 0
        case _?:    return 1
        }
    }
}
