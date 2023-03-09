import BSONTypes

extension BSON
{
    @frozen public
    struct List:Sendable
    {
        public
        var output:BSON.Output<[UInt8]>

        /// Creates an empty list.
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
extension BSON.List
{
    @inlinable public
    var bytes:[UInt8]
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
    /// Creates an encoding view around the given [`[UInt8]`]()-backed
    /// list-document.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ bson:BSON.ListView<[UInt8]>)
    {
        self.init(bytes: bson.slice)
    }
    /// Creates an encoding view around the given generic list-document,
    /// copying its backing storage if it is not already backed by
    /// a native Swift array.
    ///
    /// If the list-document is statically known to be backed by a Swift array,
    /// prefer calling the non-generic ``init(_:)``.
    ///
    /// >   Complexity:
    ///     O(1) if the opaque type is [`[UInt8]`](), O(*n*) otherwise,
    ///     where *n* is the encoded size of the document.
    @inlinable public
    init(bson:BSON.ListView<some RandomAccessCollection<UInt8>>)
    {
        switch bson
        {
        case let bson as BSON.ListView<[UInt8]>:
            self.init(bson)
        case let bson:
            self.init(bytes: .init(bson.slice))
        }
    }
}
