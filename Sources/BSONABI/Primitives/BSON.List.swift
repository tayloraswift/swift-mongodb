extension BSON
{
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
extension BSON.List
{
    @inlinable public
    var bytes:ArraySlice<UInt8>
    {
        self.output.destination
    }
}
extension BSON.List:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Never...)
    {
        self.init()
    }
}
extension BSON.List
{
    @available(*, deprecated, renamed: "init(bson:)")
    @inlinable public
    init(_ bson:BSON.ListView)
    {
        self.init(bson: bson)
    }
    /// Creates an encoding view around the given list-document.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(bson:BSON.ListView)
    {
        self.init(bytes: bson.slice)
    }
}
