import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct Accumulator:Sendable
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
extension Mongo.Accumulator:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.Accumulator:BSONDecodable
{
}
extension Mongo.Accumulator:BSONEncodable
{
}

extension Mongo.Accumulator
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
    subscript(key:SuperlativeSort) -> SuperlativeSortDocument<Mongo.SortDocument.Count>?
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
