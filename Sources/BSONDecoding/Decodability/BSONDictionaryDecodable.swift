import BSONUnions

/// A type that can be decoded from a BSON dictionary-decoder.
public
protocol BSONDictionaryDecodable:BSONDocumentDecodable
{
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
}
extension BSONDictionaryDecodable
{
    @inlinable public
    init(bson:BSON.Document<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(fields: try bson.parse()))
    }
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
        // this skips the step of creating a dictionary of ``AnyBSON``
        let fields:[(key:String, value:AnyBSON<Bytes.SubSequence>)] = try bson.parse()
        self.init(minimumCapacity: fields.count)
        for (key, value):(String, AnyBSON<Bytes.SubSequence>) in fields
        {
            if case _? = self.updateValue(try .init(bson: value), forKey: key)
            {
                throw BSON.DictionaryKeyError.duplicate(key)
            }
        }
    }
}
