import BSONTraversal

extension BSON
{
    /// A BSON tuple. The backing storage of this type is opaque,
    /// permitting lazy parsing of its inline content.
    @frozen public
    struct Tuple<Bytes> where Bytes:RandomAccessCollection<UInt8>
    {
        public
        let document:BSON.Document<Bytes>

        @inlinable public
        init(bytes:Bytes)
        {
            self.document = .init(bytes: bytes)
        }
    }
}
extension BSON.Tuple:Equatable
{
    /// Performs an exact byte-wise comparison on two tuples.
    /// Does not parse or validate the operands.
    @inlinable public static
    func == (lhs:Self, rhs:BSON.Tuple<some RandomAccessCollection<UInt8>>) -> Bool
    {
        lhs.document == rhs.document
    }
}
extension BSON.Tuple:Sendable where Bytes:Sendable
{
}
extension BSON.Tuple:VariableLengthBSON
{
    public
    typealias Frame = BSON.DocumentFrame

    /// Stores the argument in ``bytes`` unchanged. Equivalent to ``init(bytes:)``.
    ///
    /// >   Complexity: O(1)
    @inlinable public
    init(slicing bytes:Bytes)
    {
        self.init(bytes: bytes)
    }
}
extension BSON.Tuple
{
    /// The raw data backing this tuple. This collection *does*
    /// include the trailing null byte that appears after its inline 
    /// elements list.
    @inlinable public
    var bytes:Bytes
    {
        self.document.bytes
    }
    /// The length that would be encoded in this tuple’s prefixed header.
    /// Equal to [`self.size`]().
    @inlinable public
    var header:Int32
    {
        .init(self.size)
    }

    /// The size of this tuple when encoded with its header and trailing null byte.
    /// This *is* the same as the length encoded in the header itself.
    @inlinable public
    var size:Int
    {
        5 + self.bytes.count
    }
}
