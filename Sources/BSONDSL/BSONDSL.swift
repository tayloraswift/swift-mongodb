import BSON

/// A `BSONDSL` is nothing more than a wrapper around some raw BSON document
/// storage that supports an ``init(with:)`` builder API. Conforming to this
/// protocol enables automatic `BSONDecodable` and `BSONEncodable`
/// conformances, if the corresponding modules have been imported.
///
/// A `BSONDSL`-conforming type is only required to ensure that it generates
/// a document, and not some other kind of BSON value, such as an array.
///
/// The specific encoding API vended and encodability protocol used is up to
/// the conforming type.
public
protocol BSONDSL:ExpressibleByDictionaryLiteral where Key == String, Value == Never
{
    init(bytes:[UInt8])

    var bytes:[UInt8] { get }
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
    @inlinable public
    init(dictionaryLiteral:(String, Never)...)
    {
        self.init(bytes: [])
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
