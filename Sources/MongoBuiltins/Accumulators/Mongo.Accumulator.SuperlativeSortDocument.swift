import BSONDecoding
import BSONEncoding

extension Mongo.Accumulator
{
    @frozen public
    struct SuperlativeSortDocument<Count>:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.Accumulator.SuperlativeSortDocument:BSONDecodable
{
}
extension Mongo.Accumulator.SuperlativeSortDocument:BSONEncodable
{
}

extension Mongo.Accumulator.SuperlativeSortDocument
{
    @inlinable public
    subscript(key:Mongo.SortDocument.By) -> Mongo.SortDocument?
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
    subscript<Encodable>(key:Mongo.SortDocument.Output) -> Encodable?
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
}
extension Mongo.Accumulator.SuperlativeSortDocument<Mongo.SortDocument.Count>
{
    @inlinable public
    subscript<Encodable>(key:Mongo.SortDocument.Count) -> Encodable?
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
}
