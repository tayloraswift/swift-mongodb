import BSONUnions

/// A type that can be decoded from a BSON array-decoder.
public
protocol BSONArrayDecodable:BSONListDecodable
{
    init(bson:BSON.Array<some RandomAccessCollection<UInt8>>) throws
}
extension BSONArrayDecodable
{
    @inlinable public
    init(bson:BSON.ListView<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try bson.array())
    }
}
