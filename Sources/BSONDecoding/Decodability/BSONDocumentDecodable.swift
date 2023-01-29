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
}
extension Dictionary:BSONDocumentDecodable, BSONDecodable
    where Key == String, Value:BSONDecodable
{
    /// Decodes an unordered dictionary from the given document. Dictionaries
    /// are not ``BSONEncodable``, because round-tripping them loses the field
    /// ordering information.
    @inlinable public
    init<Bytes>(bson:BSON.Document<Bytes>) throws
    {
        self.init()
        try bson.parse
        {
            if case _? = self.updateValue(try $0.decode(to: Value.self), forKey: $0.key)
            {
                throw BSON.DictionaryKeyError.duplicate($0.key)
            }
        }
    }
}
