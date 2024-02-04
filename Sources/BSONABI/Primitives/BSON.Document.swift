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
        var output:BSON.Output

        /// Creates an empty document.
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
extension BSON.Document
{
    @inlinable public
    var bytes:ArraySlice<UInt8>
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
    @available(*, deprecated, renamed: "init(bson:)")
    @inlinable public
    init(_ bson:BSON.DocumentView)
    {
        self.init(bson: bson)
    }
    /// Convert a native array-backed document view to a document.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(bson:BSON.DocumentView)
    {
        self.init(bytes: bson.slice)
    }
}
extension BSON.Document
{
    @inlinable public mutating
    func append(contentsOf other:Self)
    {
        self.output.append(other.bytes)
    }
}
