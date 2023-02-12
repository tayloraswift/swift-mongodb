import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct SortOperator:Sendable
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
extension Mongo.SortOperator:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.SortOperator:BSONEncodable
{
}
extension Mongo.SortOperator:BSONDecodable
{
}

extension Mongo.SortOperator
{
    @inlinable public
    subscript(key:Meta) -> Metadata?
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
