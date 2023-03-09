import BSONTraversal

extension BSON
{
    /// A BSON list. The backing storage of this type is opaque,
    /// permitting lazy parsing of its inline content.
    @frozen public
    struct ListView<Bytes> where Bytes:RandomAccessCollection<UInt8>
    {
        public
        let document:BSON.DocumentView<Bytes>

        @inlinable public
        init(slice:Bytes)
        {
            self.document = .init(slice: slice)
        }
    }
}
extension BSON.ListView:Equatable
{
    /// Performs an exact byte-wise comparison on two lists.
    /// Does not parse or validate the operands.
    @inlinable public static
    func == (lhs:Self, rhs:BSON.ListView<some RandomAccessCollection<UInt8>>) -> Bool
    {
        lhs.document == rhs.document
    }
}
extension BSON.ListView:Sendable where Bytes:Sendable
{
}
extension BSON.ListView:VariableLengthBSON
{
    public
    typealias Frame = BSON.DocumentFrame

    /// Stores the argument in ``slice`` unchanged. Equivalent to ``init(slice:)``.
    ///
    /// >   Complexity: O(1)
    @inlinable public
    init(slicing bytes:Bytes)
    {
        self.init(slice: bytes)
    }
}
extension BSON.ListView:BSONView
{
    @inlinable public
    init(_ value:BSON.AnyValue<Bytes>) throws
    {
        self = try value.cast(with: \.list)
    }
}
extension BSON.ListView
{
    /// The raw data backing this list. This collection *does not*
    /// include the trailing null byte that appears after its inline 
    /// elements list.
    @inlinable public
    var slice:Bytes
    {
        self.document.slice
    }
    /// The length that would be encoded in this list’s prefixed header.
    /// Equal to [`self.size`]().
    @inlinable public
    var header:Int32
    {
        .init(self.size)
    }

    /// The size of this list when encoded with its header and trailing null byte.
    /// This *is* the same as the length encoded in the header itself.
    @inlinable public
    var size:Int
    {
        5 + self.slice.count
    }
}
