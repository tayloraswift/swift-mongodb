import BSONDecoding
import BSONEncoding
import MongoDSL

extension Mongo.Accumulator
{
    @frozen public
    struct SuperlativeDocument:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.Accumulator.SuperlativeDocument:BSONDecodable
{
}
extension Mongo.Accumulator.SuperlativeDocument:BSONEncodable
{
}

extension Mongo.Accumulator.SuperlativeDocument
{
    @inlinable public
    subscript<Encodable>(key:Mongo.SortDocument.Input) -> Encodable?
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
