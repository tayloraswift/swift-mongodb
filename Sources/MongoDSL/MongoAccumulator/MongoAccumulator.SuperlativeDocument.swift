import BSONDecoding
import BSONEncoding

extension MongoAccumulator
{
    @frozen public
    struct SuperlativeDocument:Sendable
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
extension MongoAccumulator.SuperlativeDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoAccumulator.SuperlativeDocument:BSONDecodable
{
}
extension MongoAccumulator.SuperlativeDocument:BSONEncodable
{
}

extension MongoAccumulator.SuperlativeDocument
{
    @inlinable public
    subscript<Encodable>(key:MongoSortOrdering.Input) -> Encodable?
        where Encodable:MongoExpressionEncodable
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
    @inlinable public
    subscript<Encodable>(key:MongoSortOrdering.Count) -> Encodable?
        where Encodable:MongoExpressionEncodable
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
