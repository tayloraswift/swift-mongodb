import BSONUnions

/// A type that can be decoded from a BSON tuple-document only.
public
protocol BSONTupleDecodable:BSONDecodable
{
    init(bson:BSON.Tuple<some RandomAccessCollection<UInt8>>) throws
}
extension BSONTupleDecodable
{
    @inlinable public
    init(bson:AnyBSON<some RandomAccessCollection<UInt8>>) throws
    {
        try self.init(bson: try .init(bson))
    }
}
extension Array:BSONTupleDecodable, BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.Tuple<some RandomAccessCollection<UInt8>>) throws
    {
        self.init()
        try bson.parse
        {
            self.append(try $0.decode(to: Element.self))
        }
    }
}
extension Set:BSONTupleDecodable, BSONDecodable where Element:BSONDecodable
{
    @inlinable public
    init(bson:BSON.Tuple<some RandomAccessCollection<UInt8>>) throws
    {
        self.init()
        try bson.parse
        {
            self.update(with: try $0.decode(to: Element.self))
        }
    }
}
