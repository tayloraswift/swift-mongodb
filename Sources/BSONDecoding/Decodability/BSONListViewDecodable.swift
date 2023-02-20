import BSONUnions

/// A type that can be decoded from a BSON list-document only.
public
protocol BSONListViewDecodable:BSONDecodable
{
    init(bson:BSON.ListView<some RandomAccessCollection<UInt8>>) throws
}
extension BSONListViewDecodable
{
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(bson))
    }
}
extension Array:BSONListViewDecodable, BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.ListView<some RandomAccessCollection<UInt8>>) throws
    {
        self.init()
        try bson.parse
        {
            self.append(try $0.decode(to: Element.self))
        }
    }
}
extension Set:BSONListViewDecodable, BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.ListView<some RandomAccessCollection<UInt8>>) throws
    {
        self.init()
        try bson.parse
        {
            self.update(with: try $0.decode(to: Element.self))
        }
    }
}
