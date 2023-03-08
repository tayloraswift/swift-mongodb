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
extension BSON.Document:BSONDocumentViewDecodable, BSONDecodable
{
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
            (field:BSON.ExplicitField<BSON.Key, Bytes.SubSequence>) in

            if case _? = self.updateValue(try field.decode(to: Value.self),
                forKey: field.key.rawValue)
            {
                throw BSON.DocumentKeyError<String>.duplicate(field.key.rawValue)
            }
        }
    }
}
