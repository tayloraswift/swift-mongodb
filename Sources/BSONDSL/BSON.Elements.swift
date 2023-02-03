import BSON

extension BSON
{
    @frozen public
    struct Elements<DSL>:Sendable
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
extension BSON.Elements
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
extension BSON.Elements:ExpressibleByArrayLiteral
{
    @inlinable public
    init(arrayLiteral:Never...)
    {
        self.init()
    }
}
extension BSON.Elements
{
    /// Creates an empty encoding view and initializes it with the given closure.
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init()
        try populate(&self)
    }

    @inlinable public
    init(_ other:BSON.Elements<some Any>)
    {
        self.init(bytes: other.bytes, count: other.count)
    }
    /// Creates an encoding view around the given [`[UInt8]`]()-backed
    /// tuple-document.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ bson:BSON.Tuple<[UInt8]>, count:Int)
    {
        self.init(bytes: bson.bytes, count: count)
    }
    /// Creates an encoding view around the given generic tuple-document,
    /// copying its backing storage if it is not already backed by
    /// a native Swift array.
    ///
    /// If the tuple-document is statically known to be backed by a Swift array,
    /// prefer calling the non-generic ``init(_:)``.
    ///
    /// >   Complexity:
    ///     O(1) if the opaque type is [`[UInt8]`](), O(*n*) otherwise,
    ///     where *n* is the encoded size of the document.
    @inlinable public
    init(bson:BSON.Tuple<some RandomAccessCollection<UInt8>>, count:Int)
    {
        switch bson
        {
        case let bson as BSON.Tuple<[UInt8]>:
            self.init(bson, count: count)
        case let bson:
            self.init(bytes: .init(bson.bytes), count: count)
        }
    }
}
