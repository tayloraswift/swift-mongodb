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
    init(bson:BSON.DocumentView<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try bson.dictionary())
    }
}
