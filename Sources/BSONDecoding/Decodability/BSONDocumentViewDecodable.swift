import BSONUnions

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
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(bson))
    }
}
extension Dictionary:BSONDocumentViewDecodable, BSONDecodable
    where Key == String, Value:BSONDecodable
{
    /// Decodes an unordered dictionary from the given document. Dictionaries
    /// are not ``BSONEncodable``, because round-tripping them loses the field
    /// ordering information.
    @inlinable public
    init<Bytes>(bson:BSON.DocumentView<Bytes>) throws
    {
        self.init()
        try bson.parse
        {
            if case _? = self.updateValue(try $0.decode(to: Value.self), forKey: $0.key)
            {
                throw BSON.DocumentKeyError<String>.duplicate($0.key)
            }
        }
    }
}
