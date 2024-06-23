import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct SortArrayDocument:Mongo.EncodableDocument, Sendable
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
extension Mongo.SortArrayDocument
{
    @frozen public
    enum Input:String, Sendable
    {
        case input
    }

    @inlinable public
    subscript<Encodable>(key:Input) -> Encodable?
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
    subscript<CodingKey>(key:Mongo.SortBy,
        using _:CodingKey.Type = CodingKey.self,
        yield:(inout Mongo.SortEncoder<CodingKey>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.SortEncoder<CodingKey>.self])
        }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(key:Mongo.SortBy) -> Mongo.SortDocument<Mongo.AnyKeyPath>?
    {
        nil
    }
}
