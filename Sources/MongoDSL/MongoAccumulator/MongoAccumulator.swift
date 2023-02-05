import BSONDecoding
import BSONEncoding

@frozen public
struct MongoAccumulator:Sendable
{
    public
    var fields:BSON.Fields

    @inlinable public
    init(bytes:[UInt8] = [])
    {
        self.fields = .init(bytes: bytes)
    }
}
extension MongoAccumulator:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension MongoAccumulator:BSONDecodable
{
}
extension MongoAccumulator:BSONEncodable
{
}

extension MongoAccumulator
{
    @inlinable public
    subscript(key:Count) -> [String: Never]?
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
    subscript<Encodable>(key:Unary) -> Encodable?
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
    subscript<Encodable>(key:Superlative) -> Encodable?
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
    subscript(key:Superlative) -> SuperlativeDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key.n] = value
        }
    }
    @inlinable public
    subscript(key:SuperlativeSort) -> SuperlativeSortDocument<Never>?
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
    @_disfavoredOverload
    @inlinable public
    subscript(key:SuperlativeSort) -> SuperlativeSortDocument<MongoSortOrdering.Count>?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[pushing: key.n] = value
        }
    }
}
