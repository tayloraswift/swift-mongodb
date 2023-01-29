import BSONUnions

/// A type that can be decoded from a BSON array-decoder.
public
protocol BSONArrayDecodable:BSONTupleDecodable
{
    init(bson:BSON.Array<some RandomAccessCollection<UInt8>>) throws
}
extension BSONArrayDecodable
{
    @inlinable public
    init(bson:BSON.Tuple<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try bson.array())
    }
}
