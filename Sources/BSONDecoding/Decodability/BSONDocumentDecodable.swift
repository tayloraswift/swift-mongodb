/// A type that can be decoded from a BSON dictionary-decoder.
public
protocol BSONDocumentDecodable<CodingKey>:BSONDecodable
{
    associatedtype CodingKey:RawRepresentable<String> & Hashable & Sendable = BSON.Key

    init(bson:BSON.DocumentDecoder<CodingKey>) throws
}
extension BSONDocumentDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        try self.init(bson: try .init(parsing: bson))
    }

    @inlinable public
    init(bson:BSON.Document) throws
    {
        try self.init(bson: try .init(parsing: bson))
    }
}
