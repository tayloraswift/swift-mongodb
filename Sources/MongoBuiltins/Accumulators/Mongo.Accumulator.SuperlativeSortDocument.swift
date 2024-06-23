import BSON

extension Mongo.Accumulator
{
    @frozen public
    struct SuperlativeSortDocument<Count>:Mongo.EncodableDocument, Sendable
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
extension Mongo.Accumulator.SuperlativeSortDocument
{
    @available(*, unavailable)
    @inlinable public
    subscript(key:Mongo.SortBy) -> Mongo.SortDocument<Mongo.AnyKeyPath>?
    {
        nil
    }

    @inlinable public
    subscript<CodingKey>(key:Mongo.SortBy,
        using _:CodingKey.Type = CodingKey.self,
        yield:(inout Mongo.SortEncoder<CodingKey>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.SortEncoder<CodingKey>.self])
        }
    }
}
extension Mongo.Accumulator.SuperlativeSortDocument
{
    @frozen public
    enum Output:String, Hashable, Sendable
    {
        case output
    }

    @inlinable public
    subscript<Encodable>(key:Output) -> Encodable?
        where Encodable:BSONEncodable
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.Accumulator.SuperlativeSortDocument<Mongo.Accumulator.N>
{

    @inlinable public
    subscript<Encodable>(key:Mongo.Accumulator.N) -> Encodable?
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
}
