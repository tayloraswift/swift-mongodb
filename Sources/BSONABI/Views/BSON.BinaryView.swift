extension BSON
{
    /// A BSON binary array.
    @frozen public
    struct BinaryView<Bytes> where Bytes:RandomAccessCollection<UInt8>
    {
        /// The contents of this binary array. This collection does *not*
        /// include the leading subtype byte.
        public
        let bytes:Bytes
        /// The subtype of this binary array.
        public
        let subtype:BinarySubtype

        @inlinable public
        init(subtype:BinarySubtype, bytes:Bytes)
        {
            self.subtype = subtype
            self.bytes = bytes
        }
    }
}
extension BSON.BinaryView:Sendable where Bytes:Sendable
{
}
extension BSON.BinaryView:Equatable
{
    /// Performs an exact byte-wise comparison on two binary arrays.
    /// The subtypes must match as well.
    @inlinable public static
    func == (lhs:Self, rhs:BSON.BinaryView<some RandomAccessCollection<UInt8>>) -> Bool
    {
        lhs.subtype == rhs.subtype &&
        lhs.bytes.elementsEqual(rhs.bytes)
    }
}
extension BSON.BinaryView<ArraySlice<UInt8>>:BSON.BufferTraversable
{
    public
    typealias Frame = BSON.BinaryFrame

    /// Removes the first element of the argument, attempts to cast it to a
    /// ``BinarySubtype``, and stores the remainder in ``bytes``.
    ///
    /// If the subtype is the deprecated generic subtype (code [`0x02`]()),
    /// the inner length header will be stripped from ``bytes`` and ignored.
    ///
    /// >   Complexity: O(1)
    @inlinable public
    init(slicing bytes:ArraySlice<UInt8>) throws
    {
        guard let code:UInt8 = bytes.first
        else
        {
            throw BSON.BinaryViewError.init(expected: .subtype)
        }
        guard let subtype:BSON.BinarySubtype = .init(rawValue: code)
        else
        {
            throw BSON.BinarySubtypeError.init(invalid: code)
        }

        let start:Int = bytes.index(after: bytes.startIndex)
        if code != 0x02
        {
            self.init(subtype: subtype, bytes: bytes[start...])
        }
        // special handling for legacy binary format 0x02
        else if let start:Int = bytes.index(start, offsetBy: 4,
                    limitedBy: bytes.endIndex)
        {
            self.init(subtype: subtype, bytes: bytes.suffix(from: start))
        }
        else
        {
            throw BSON.BinaryViewError.init(expected: .subheader)
        }
    }
}
extension BSON.BinaryView
{
    /// The length that would be encoded in this binary array’s prefixed header.
    /// Equal to [`self.bytes.count`]().
    @inlinable public
    var header:Int32
    {
        .init(self.bytes.count)
    }
    /// The size of this binary array when encoded with its header.
    /// This is *not* the length encoded in the header itself.
    @inlinable public
    var size:Int
    {
        5 + self.bytes.count
    }
}
