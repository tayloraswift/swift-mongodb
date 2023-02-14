import BSON

extension BSON
{
    @frozen public
    struct List<DSL>:Sendable
    {
        public
        var output:BSON.Output<[UInt8]>
        public
        var count:Int

        @inlinable public
        init()
        {
            self.init(bytes: [], count: 0)
        }
        @inlinable public
        init(bytes:[UInt8], count:Int)
        {
            self.output = .init(preallocated: bytes)
            self.count = count
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
    @inlinable public
    var isEmpty:Bool
    {
        self.bytes.isEmpty
    }
    @inlinable public mutating
    func append(with serialize:(inout BSON.Field) -> ())
    {
        self.output.with(key: self.count.description, do: serialize)
        self.count += 1
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
    /// Creates an empty encoding view and initializes it with the given closure.
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }

    @inlinable public
    init(_ other:BSON.List<some Any>)
    {
        self.init(bytes: other.bytes, count: other.count)
    }
    /// Creates an encoding view around the given [`[UInt8]`]()-backed
    /// list-document.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ bson:BSON.ListView<[UInt8]>, count:Int)
    {
        self.init(bytes: bson.slice, count: count)
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
    init(bson:BSON.ListView<some RandomAccessCollection<UInt8>>, count:Int)
    {
        switch bson
        {
        case let bson as BSON.ListView<[UInt8]>:
            self.init(bson, count: count)
        case let bson:
            self.init(bytes: .init(bson.slice), count: count)
        }
    }
}
//  See note about ``BSON.Document``.
extension BSON.List<BSON.Document>?
{
    @inlinable public
    init(with populate:(inout Wrapped) throws -> ()) rethrows
    {
        self = .some(try .init(with: populate))
    }
}
