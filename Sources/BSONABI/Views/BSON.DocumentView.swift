extension BSON
{
    /// A BSON document. The backing storage of this type is opaque,
    /// permitting lazy parsing of its inline content.
    @frozen public
    struct DocumentView:Sendable
    {
        /// The raw data backing this document. This collection *does not*
        /// include the trailing null byte that typically appears after its
        /// inline field list.
        public
        let slice:ArraySlice<UInt8>

        /// Stores the argument in ``slice`` unchanged.
        ///
        /// >   Complexity: O(1)
        @inlinable public
        init(slice:ArraySlice<UInt8>)
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
    func == (lhs:Self, rhs:BSON.DocumentView) -> Bool
    {
        lhs.slice.elementsEqual(rhs.slice)
    }
}
extension BSON.DocumentView:BSON.FrameTraversable
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
extension BSON.DocumentView:BSON.FrameView
{
    @inlinable public
    init(_ value:BSON.AnyValue) throws
    {
        self = try value.cast(with: \.document)
    }
}
extension BSON.DocumentView
{
    /// Indicates if this document contains no fields.
    @inlinable public
    var isEmpty:Bool { self.slice.isEmpty }

    /// The length that would be encoded in this document’s prefixed header.
    /// Equal to ``size``.
    @inlinable public
    var header:Int32 { .init(self.size) }

    /// The size of this document when encoded with its header and trailing
    /// null byte. This *is* the same as the length encoded in the header itself.
    @inlinable public
    var size:Int { 5 + self.slice.count }
}

extension BSON.DocumentView
{
    /// Wraps the **entire** storage buffer of the given document into an instance of this type.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ document:BSON.Document)
    {
        self.init(slice: document.bytes[...])
    }
}

extension BSON.DocumentView
{
    /// Parses this document into key-value pairs in order, yielding each key-value
    /// pair to the provided closure.
    ///
    /// Unlike ``parse(_:)``, this method does not allocate storage for the parsed key-value
    /// pairs. (But it does allocate storage to provide a ``String`` representation for
    /// each visited key.)
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the size of this document’s backing storage.
    @inlinable public
    func parse<CodingKey>(
        to decode:(CodingKey, BSON.AnyValue) throws -> ()) throws
        where CodingKey:RawRepresentable<String>
    {
        var input:BSON.Input = .init(self.slice)
        while let code:UInt8 = input.next()
        {
            let type:BSON.AnyType = try .init(code: code)
            let key:String = try input.parse(as: String.self)
            //  We must parse the value always, even if we are ignoring the key
            let value:BSON.AnyValue = try input.parse(variant: type)

            if let key:CodingKey = .init(rawValue: key)
            {
                try decode(key, value)
            }
        }
    }
    /// Splits this document’s inline key-value pairs into an array.
    ///
    /// Calling this convenience method is the same as calling ``parse(to:)`` and
    /// collecting the yielded key-value pairs in an array.
    ///
    /// >   Complexity:
    ///     O(*n*), where *n* is the size of this document’s backing storage.
    @inlinable public
    func parse<CodingKey, T>(
        _ transform:(_ key:CodingKey, _ value:BSON.AnyValue) throws -> T) throws -> [T]
        where CodingKey:RawRepresentable<String>
    {
        var elements:[T] = []
        try self.parse
        {
            elements.append(try transform($0, $1))
        }
        return elements
    }
}
extension BSON.DocumentView:ExpressibleByDictionaryLiteral
{
    /// Creates a document containing the given fields, making two passes over
    /// the list of fields in order to encode the output without reallocations.
    /// The order of the fields will be preserved.
    @inlinable public
    init(fields:some Collection<(key:BSON.Key, value:BSON.AnyValue)>)
    {
        let size:Int = fields.reduce(0) { $0 + 2 + $1.key.rawValue.utf8.count + $1.value.size }
        var output:BSON.Output = .init(capacity: size)
            output.serialize(fields: fields)

        assert(output.destination.count == size, """
            precomputed size (\(size)) does not match output size (\(output.destination.count))
            """)

        self.init(slice: output.destination)
    }

    /// Creates a document containing a single key-value pair.
    @inlinable public
    init(key:BSON.Key, value:BSON.AnyValue)
    {
        self.init(fields:
            CollectionOfOne<(key:BSON.Key, value:BSON.AnyValue)>.init((key, value)))
    }

    @inlinable public
    init(dictionaryLiteral:(BSON.Key, BSON.AnyValue)...)
    {
        self.init(fields: dictionaryLiteral)
    }
}
