/// A BSON view that parsers can traverse in constant time.
///
/// BSON parsers typically parse conforming types by reading a length
/// header from raw input data, and using it to slice the input,
/// ideally without copying backing storage. The interpretation of the
/// length header is specified by the ``Frame`` type requirement, and
/// the exact slicing behavior is determined by the implementation’s
/// ``init(slicing:)`` witness.
public
protocol VariableLengthBSON<Bytes>
{
    /// The backing storage used by this type. I recommend satisfying
    /// this with generics, to avoid copying input data.
    associatedtype Bytes:RandomAccessCollection<UInt8>
    /// The type specifying how parsers should interpret the conforming
    /// type’s inline frame header when it appears in raw input data.
    associatedtype Frame:VariableLengthBSONFrame

    /// Receives a collection of bytes encompassing the bytes backing
    /// this value, after stripping the length header and frame suffix,
    /// but keeping any portions of the frame prefix that are not part
    /// of the length header.
    ///
    /// The implementation may slice the argument, but should do so in
    /// O(1) time.
    init(slicing:Bytes) throws

    /// The slice of bytes constituting the opaque content of this view.
    /// The conforming type defines what portion of the original buffer
    /// this slice includes, and it may not cover the entirety of the
    /// argument originally passed to ``init(slicing:)``.
    var slice:Bytes { get }
}
