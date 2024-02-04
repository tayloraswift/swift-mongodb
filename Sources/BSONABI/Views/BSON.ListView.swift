extension BSON
{
    /// A BSON list. The backing storage of this type is opaque,
    /// permitting lazy parsing of its inline content.
    @frozen public
    struct ListView:Sendable
    {
        public
        let document:BSON.DocumentView

        @inlinable public
        init(slice:ArraySlice<UInt8>)
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
    func == (lhs:Self, rhs:BSON.ListView) -> Bool
    {
        lhs.document == rhs.document
    }
}
extension BSON.ListView:BSON.FrameTraversable
{
    public
    typealias Frame = BSON.DocumentFrame

    /// Stores the argument in ``slice`` unchanged. Equivalent to ``init(slice:)``.
    ///
    /// >   Complexity: O(1)
    @inlinable public
    init(slicing bytes:ArraySlice<UInt8>)
    {
        self.init(slice: bytes)
    }
}
extension BSON.ListView:BSON.FrameView
{
    @inlinable public
    init(_ value:BSON.AnyValue) throws
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
    var slice:ArraySlice<UInt8> { self.document.slice }

    /// Indicates if this list contains no elements.
    @inlinable public
    var isEmpty:Bool { self.slice.isEmpty }

    /// The length that would be encoded in this list’s prefixed header.
    /// Equal to ``size``.
    @inlinable public
    var header:Int32 { .init(self.size) }

    /// The size of this list when encoded with its header and trailing
    /// null byte. This *is* the same as the length encoded in the header
    /// itself.
    @inlinable public
    var size:Int { 5 + self.slice.count }
}

extension BSON.ListView
{
    /// Wraps the **entire** storage buffer of the given list in an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ list:BSON.List)
    {
        self.init(slice: list.bytes[...])
    }
}

extension BSON.ListView
{
    /// Parses this list into key-value pairs in order, yielding each value to the
    /// provided closure. Parsing a list is slightly faster than parsing a general
    /// ``DocumentView``, because this method ignores the document keys.
    ///
    /// This method does *not* perform any key validation.
    ///
    /// Unlike ``parse``, this method does not allocate storage for the parsed
    /// elements.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the size of this list’s backing storage.
    @inlinable public
    func parse(to decode:(_ element:BSON.AnyValue) throws -> ()) throws
    {
        var input:BSON.Input = .init(self.slice)
        while let code:UInt8 = input.next()
        {
            let type:BSON.AnyType = try .init(code: code)
            try input.parse(through: 0x00)
            try decode(try input.parse(variant: type))
        }
    }
    @inlinable public
    func parse<T>(
        _ transform:(_ element:BSON.AnyValue) throws -> T) throws -> [T]
    {
        var elements:[T] = []
        try self.parse
        {
            elements.append(try transform($0))
        }
        return elements
    }
    /// Splits this list’s inline key-value pairs into an array containing the
    /// values only. Parsing a list is slightly faster than parsing a general
    /// ``DocumentView``, because this method ignores the document keys.
    ///
    /// This method does *not* perform any key validation.
    ///
    /// Calling this convenience method is the same as calling ``parse(to:)`` and
    /// collecting the yielded elements in an array.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the size of this list’s backing storage.
    @inlinable public
    func parse() throws -> [BSON.AnyValue]
    {
        try self.parse { $0 }
    }
}
extension BSON.ListView:ExpressibleByArrayLiteral
{
    /// Creates a list-document containing the given elements.
    @inlinable public
    init(elements:some Sequence<BSON.AnyValue>)
    {
        // we do need to precompute the ordinal keys, so we know the total length
        // of the document.
        let document:BSON.DocumentView = .init(fields: elements.enumerated().map
        {
            (.init(index: $0.0), $0.1)
        })
        self.init(slice: document.slice)
    }

    @inlinable public
    init(arrayLiteral:BSON.AnyValue...)
    {
        self.init(elements: arrayLiteral)
    }
}
