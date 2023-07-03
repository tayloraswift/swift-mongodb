/// A type that can be decoded from a BSON list-document only.
public
protocol BSONListViewDecodable:BSONDecodable
{
    init(bson:BSON.ListView<some RandomAccessCollection<UInt8>>) throws
}
extension BSONListViewDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(bson))
    }
}
