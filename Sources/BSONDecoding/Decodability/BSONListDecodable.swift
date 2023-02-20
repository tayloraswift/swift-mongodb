import BSONUnions

/// A type that can be decoded from a BSON array-decoder.
public
protocol BSONListDecodable:BSONListViewDecodable
{
    init(bson:BSON.ListDecoder<some RandomAccessCollection<UInt8>>) throws
}
extension BSONListDecodable
{
    @inlinable public
    init(bson:BSON.ListView<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(parsing: bson))
    }
}
