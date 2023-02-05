import BSONDecoding
import BSONEncoding

extension MongoAccumulator
{
    @frozen public
    struct SuperlativeSortDocument<Count>:Sendable
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
extension MongoAccumulator.SuperlativeSortDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoAccumulator.SuperlativeSortDocument:BSONDecodable
{
}
extension MongoAccumulator.SuperlativeSortDocument:BSONEncodable
{
}

extension MongoAccumulator.SuperlativeSortDocument
{
    @inlinable public
    subscript(key:MongoSortOrdering.By) -> MongoSortOrdering?
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
    subscript<Encodable>(key:MongoSortOrdering.Output) -> Encodable?
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
extension MongoAccumulator.SuperlativeSortDocument<MongoSortOrdering.Count>
{
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
