/// A type that can be decoded from a BSON dictionary-decoder.
public
protocol BSONDocumentDecodable<CodingKey>:BSONDocumentViewDecodable
{
    associatedtype CodingKey:RawRepresentable<String> & Hashable = BSON.Key

    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
}
extension BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentView<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(parsing: bson))
    }
}
