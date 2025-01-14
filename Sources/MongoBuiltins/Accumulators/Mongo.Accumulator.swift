import BSON

extension Mongo
{
    @frozen public
    struct Accumulator:Mongo.EncodableDocument, Sendable
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
extension Mongo.Accumulator
{
    @inlinable public
    subscript(key:Count) -> Mongo.EmptyDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
    @inlinable public
    subscript<Encodable>(key:Unary) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
    @inlinable public
    subscript<Encodable>(key:Superlative) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
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
            value?.encode(to: &self.bson[with: key.n])
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
            value?.encode(to: &self.bson[with: key])
        }
    }
    @_disfavoredOverload
    @inlinable public
    subscript(key:SuperlativeSort) -> SuperlativeSortDocument<N>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key.n])
        }
    }
}
