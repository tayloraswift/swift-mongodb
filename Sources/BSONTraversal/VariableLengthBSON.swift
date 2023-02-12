/// A BSON value that supports random-access traversal.
public
protocol VariableLengthBSON<Bytes>
{
    /// The backing storage used by this type. It is recommended that 
    /// implementations satisfy this with generics.
    associatedtype Bytes:RandomAccessCollection<UInt8>
    /// The length header associated with this type. This is specified as an
    /// associated type, so that it can be independent of the ``Bytes`` type.
    associatedtype Frame:VariableLengthBSONFrame

    /// Receives a collection of bytes encompassing the bytes
    /// backing this value, after stripping the length header
    /// and frame suffix, but keeping any portions of the frame
    /// prefix that are not part of the length header.
    ///
    /// The implementation may slice the argument, but should do so in O(1) time.
    init(slicing:Bytes) throws

    /// The slice of bytes constituting the opaque content this view.
    /// The portion of the original buffer this instance was parsed from
    /// is defined by the implementation, and may not cover the entirety
    /// of the argument passed to ``init(slicing:)``.
    var slice:Bytes { get }
}
