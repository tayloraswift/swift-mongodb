extension BSON
{
    @available(*, deprecated, message: "BSON.ListView has been merged with BSON.List")
    public
    typealias ListView = List

    @frozen public
    struct List:Sendable
    {
        public
        var output:BSON.Output

        /// Creates an empty list.
        @inlinable public
        init()
        {
            self.output = .init(preallocated: [])
        }
        @inlinable public
        init(bytes:ArraySlice<UInt8>)
        {
            self.output = .init(preallocated: bytes)
        }
    }
}
extension BSON.List:BSON.BufferTraversable
{
    public
    typealias Frame = BSON.DocumentFrame

    /// Stores the argument in ``bytes`` unchanged. Equivalent to ``init(bytes:)``.
    ///
    /// >   Complexity: O(1)
    @inlinable public
    init(slicing bytes:ArraySlice<UInt8>)
    {
        self.init(bytes: bytes)
    }

    /// The raw data backing this list. This collection *does not* include the trailing null
    /// byte that appears after its inline elements list.
    @inlinable public
    var bytes:ArraySlice<UInt8> { self.output.destination }
}
extension BSON.List
{
    /// Indicates if this list contains no elements.
    @inlinable public
    var isEmpty:Bool { self.bytes.isEmpty }

    /// The length that would be encoded in this list’s prefixed header.
    /// Equal to ``size``.
    @inlinable public
    var header:Int32 { .init(self.size) }

    /// The size of this list when encoded with its header and trailing
    /// null byte. This *is* the same as the length encoded in the header
    /// itself.
    @inlinable public
    var size:Int { 5 + self.bytes.count }

    @available(*, deprecated, renamed: "BSON.Document.init(list:)")
    @inlinable public
    var document:BSON.Document { .init(list: self) }
}
extension BSON.List:Equatable
{
    /// Performs an exact byte-wise comparison on two lists.
    /// Does not parse or validate the operands.
    @inlinable public static
    func == (a:Self, b:Self) -> Bool { a.bytes.elementsEqual(b.bytes) }
}

extension BSON.List
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
        var input:BSON.Input = .init(self.bytes)
        while let code:UInt8 = input.next()
        {
            let type:BSON.AnyType = try .init(code: code)
            try input.parse(through: 0x00)
            try decode(try input.parse(variant: type))
        }
    }
    @inlinable public
    func parse<T>(_ transform:(_ element:BSON.AnyValue) throws -> T) throws -> [T]
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
    func parse() throws -> [BSON.AnyValue] { try self.parse { $0 } }
}

extension BSON.List:ExpressibleByArrayLiteral
{
    /// Creates a list-document containing the given elements.
    @inlinable public
    init(elements:some Sequence<BSON.AnyValue>)
    {
        // we do need to precompute the ordinal keys, so we know the total length
        // of the document.
        let document:BSON.Document = .init(fields: elements.enumerated().map
        {
            (.init(index: $0.0), $0.1)
        })
        self.init(bytes: document.bytes)
    }

    @inlinable public
    init(arrayLiteral:BSON.AnyValue...)
    {
        self.init(elements: arrayLiteral)
    }
}

extension BSON.List
{
    @available(*, deprecated, message: "BSON.List is already a BSON.List")
    @inlinable public
    init(_ bson:Self)
    {
        self.init(bson: bson)
    }

    @available(*, deprecated, message: "BSON.List is already a BSON.List")
    @inlinable public
    init(bson:Self)
    {
        self.init(bytes: bson.bytes)
    }

    @available(*, deprecated, renamed: "init(bytes:)")
    @inlinable public
    init(slice:ArraySlice<UInt8>)
    {
        self.init(bytes: slice)
    }
}
