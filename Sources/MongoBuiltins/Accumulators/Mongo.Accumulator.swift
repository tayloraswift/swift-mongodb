import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct Accumulator:BSONRepresentable, BSONDSL, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key.n, value)
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
            self.bson.push(key, value)
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
            self.bson.push(key.n, value)
        }
    }
}
