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
extension Dictionary:BSONDictionaryDecodable, BSONDocumentDecodable, BSONDecodable
    where Key == String, Value:BSONDecodable
{
    @inlinable public
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self = try bson.items.mapValues(Value.init(bson:))
    }
}
