/// A type that can be decoded from a BSON document. List-documents
/// count as documents, from the perspective of this protocol.
public
protocol BSONDocumentViewDecodable:BSONDecodable
{
    init(bson:BSON.DocumentView<some RandomAccessCollection<UInt8>>) throws
}
extension BSONDocumentViewDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(bson))
    }
}
