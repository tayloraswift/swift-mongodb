extension BSON
{
    /// The `Document` type models the “universal” BSON DSL.
    ///
    /// It is expected that more-specialized BSON DSLs will wrap an
    /// instance of `Document`.
    @frozen public
    struct Document:Sendable
    {
        public
        var output:BSON.Output<[UInt8]>

        /// Creates an empty document.
        @inlinable public
        init()
        {
            self.output = .init(preallocated: [])
        }
        @inlinable public
        init(bytes:[UInt8])
        {
            self.output = .init(preallocated: bytes)
        }
    }
}
extension BSON.Document
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.output.destination
    }
}
extension BSON.Document:ExpressibleByDictionaryLiteral
{
    @inlinable public
    init(dictionaryLiteral:(String, Never)...)
    {
        self.init()
    }
}

extension BSON.Document
{
    /// Convert a native array-backed document view to a document.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ bson:BSON.DocumentView<[UInt8]>)
    {
        self.init(bytes: bson.slice)
    }
    /// Convert a generically-backed document view to a document,
    /// copying its backing storage if it is not already backed by
    /// a native Swift array.
    ///
    /// If the document is statically known to be backed by a Swift array,
    /// prefer calling the non-generic ``init(_:)``.
    ///
    /// >   Complexity:
    ///     O(1) if the opaque type is [`[UInt8]`](), O(*n*) otherwise,
    ///     where *n* is the encoded size of the document.
    @inlinable public
    init(bson:BSON.DocumentView<some RandomAccessCollection<UInt8>>)
    {
        switch bson
        {
        case let bson as BSON.DocumentView<[UInt8]>:
            self.init(bson)
        case let bson:
            self.init(bytes: .init(bson.slice))
        }
    }
}
extension BSON.Document
{
    @inlinable public mutating
    func append(contentsOf other:Self)
    {
        self.output.append(other.bytes)
    }
    @inlinable public mutating
    func append(_ key:String, with encode:(inout BSON.Field) -> ())
    {
        encode(&self.output[with: .init(rawValue: key)])
    }
}
