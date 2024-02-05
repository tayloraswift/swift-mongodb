/// A type that can be decoded from a BSON dictionary-decoder.
public
protocol BSONDocumentDecodable<CodingKey>:BSONDocumentViewDecodable
{
    associatedtype CodingKey:RawRepresentable<String> & Hashable & Sendable = BSON.Key

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
}
extension BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.DocumentView) throws
    {
        try self.init(bson: try .init(parsing: bson))
    }
}
