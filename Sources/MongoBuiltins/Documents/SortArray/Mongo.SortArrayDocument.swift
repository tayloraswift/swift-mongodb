import BSONDecoding
import BSONEncoding
import MongoDSL

extension Mongo
{
    @frozen public
    struct SortArrayDocument:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.SortArrayDocument:BSONDecodable
{
}
extension Mongo.SortArrayDocument:BSONEncodable
{
}
extension Mongo.SortArrayDocument
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
}
