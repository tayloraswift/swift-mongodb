import BSONTraversal

infix operator ~~ : ComparisonPrecedence

extension BSON
{
    /// A BSON document. The backing storage of this type is opaque,
    /// permitting lazy parsing of its inline content.
    @frozen public
    struct DocumentView<Bytes> where Bytes:RandomAccessCollection<UInt8>
    {
        /// The raw data backing this document. This collection *does not*
        /// include the trailing null byte that typically appears after its
        /// inline field list.
        public 
        let slice:Bytes

        /// Stores the argument in ``slice`` unchanged.
        ///
        /// >   Complexity: O(1)
        @inlinable public
        init(slice:Bytes)
        {
            self.slice = slice
        }
    }
}
extension BSON.DocumentView:Equatable
{
    /// Performs an exact byte-wise comparison on two lists.
    /// Does not parse or validate the operands.
    @inlinable public static
    func == (lhs:Self, rhs:BSON.DocumentView<some RandomAccessCollection<UInt8>>) -> Bool
    {
        lhs.slice.elementsEqual(rhs.slice)
    }
}
extension BSON.DocumentView:Sendable where Bytes:Sendable
{
}
extension BSON.DocumentView:VariableLengthBSON
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

extension BSON.DocumentView
{
    /// The length that would be encoded in this document’s prefixed header.
    /// Equal to [`self.size`]().
    @inlinable public
    var header:Int32
    {
        .init(self.size)
    }
    
    /// The size of this document when encoded with its header and trailing null byte.
    /// This *is* the same as the length encoded in the header itself.
    @inlinable public
    var size:Int
    {
        5 + self.slice.count
    }
}

extension BSON.DocumentView:CustomStringConvertible
{
    public
    var description:String
    {
        """
        (\(self.header), \(self.slice.lazy.map 
        {
            """
            \(String.init($0 >> 4,   radix: 16, uppercase: true))\
            \(String.init($0 & 0x0f, radix: 16, uppercase: true))
            """
        }.joined(separator: "_")))
        """
    }
}
