/// A type that can be decoded from a BSON list-decoder. You should only conform to this
/// protocol if you need random-access decoding. Many arraylike data structures are
/// more-efficiently decoded from a ``BSON.List`` at the ``BSONDecodable`` level.
public
protocol BSONListDecodable:BSONDecodable
{
    init(bson:BSON.ListDecoder) throws
}
extension BSONListDecodable
{
    @inlinable public
    init(bson:BSON.AnyValue) throws
    {
        try self.init(bson: try .init(parsing: bson))
    }

    @inlinable public
    init(bson:BSON.List) throws
    {
        try self.init(bson: try .init(parsing: bson))
    }
}
