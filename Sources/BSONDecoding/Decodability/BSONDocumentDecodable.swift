import BSONUnions

/// A type that can be decoded from a BSON document. Tuple-documents
/// count as documents, from the perspective of this protocol.
public
protocol BSONDocumentDecodable:BSONDecodable
{
    init(bson:BSON.Document<some RandomAccessCollection<UInt8>>) throws
}
extension BSONDocumentDecodable
{
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(bson))
    }
}
extension BSON.Fields:BSONDocumentDecodable
{
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
            self.init(.init(bytes: .init(bson.bytes)))
        }
    }
}
