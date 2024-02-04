/// A type that can be decoded from a BSON list-decoder. You should only
/// conform to this protocol if you need random-access decoding. Most
/// list-like data structures are more-efficiently decoded at the
/// ``BSON.ListView`` level.
public
protocol BSONListDecodable:BSONListViewDecodable
{
    init(bson:BSON.ListDecoder) throws
}
extension BSONListDecodable
{
    @inlinable public
    init(bson:BSON.ListView) throws
    {
        try self.init(bson: try .init(parsing: bson))
    }
}
