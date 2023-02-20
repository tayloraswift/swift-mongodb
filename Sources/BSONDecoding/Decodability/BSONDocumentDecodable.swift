import BSONUnions

/// A type that can be decoded from a BSON dictionary-decoder.
public
protocol BSONDocumentDecodable<CodingKeys>:BSONDocumentViewDecodable
{
    associatedtype CodingKeys:Hashable = String

    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
}
extension BSONDocumentDecodable<String>
{
    @inlinable public
    init(bson:BSON.DocumentView<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try bson.decoder())
    }
}
extension BSONDocumentDecodable where CodingKeys:RawRepresentable<String>
{
    @inlinable public
    init(bson:BSON.DocumentView<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try bson.decoder(keys: CodingKeys.self))
    }
}
