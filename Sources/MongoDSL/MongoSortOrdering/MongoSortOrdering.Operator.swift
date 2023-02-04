import BSONDecoding
import BSONEncoding

extension MongoSortOrdering
{
    @frozen public
    struct Operator:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension MongoSortOrdering.Operator:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoSortOrdering.Operator:BSONEncodable
{
}
extension MongoSortOrdering.Operator:BSONDecodable
{
}

extension MongoSortOrdering.Operator
{
    @inlinable public
    subscript(key:Meta) -> MongoSortOrdering.Metadata?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key] = value
        }
    }
}
