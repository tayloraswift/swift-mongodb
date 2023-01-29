import BSON

public
protocol BSONDSL
{
    init(bytes:[UInt8])

    var bytes:[UInt8] { get }

    mutating
    func append(key:String, with serialize:(inout BSON.Field) -> ())
}
extension BSONDSL
{
    @inlinable public
    var isEmpty:Bool
    {
        self.bytes.isEmpty
    }
}
extension BSONDSL
{
    /// Creates an empty encoding view and initializes it with the given closure.
    @inlinable public
    init(with populate:(inout Self) throws -> ()) rethrows
    {
        self.init(bytes: [])
        try populate(&self)
    }
    /// Creates an encoding view around the given [`[UInt8]`]()-backed
    /// document.
    ///
    /// >   Complexity: O(1).
    @inlinable public
    init(_ bson:BSON.Document<[UInt8]>)
    {
        self.init(bytes: bson.bytes)
    }
    /// Creates an encoding view around the given generic document,
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
    init(bson:BSON.Document<some RandomAccessCollection<UInt8>>)
    {
        switch bson
        {
        case let bson as BSON.Document<[UInt8]>:
            self.init(bson)
        case let bson:
            self.init(bytes: .init(bson.bytes))
        }
    }
}

extension BSON.Fields:BSONDSL
{
}
