import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct Accumulator:Sendable
    {
        public
        var document:BSON.Document

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.document = .init(bytes: bytes)
        }
    }
}
extension Mongo.Accumulator:BSONStream
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
            self.document.push(key, value)
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
            self.document.push(key, value)
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
            self.document.push(key, value)
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
            self.document.push(key.n, value)
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
            self.document.push(key, value)
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
            self.document.push(key.n, value)
        }
    }
}
