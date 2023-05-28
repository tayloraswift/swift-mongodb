import BSONEncoding
import MongoDSL

extension Mongo
{
    /// Not to be confused with ``PredicateDocument``.
    @frozen public
    struct FilterDocument:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.FilterDocument:BSONEncodable
{
}
extension Mongo.FilterDocument
{
    @inlinable public
    subscript<Encodable>(key:Argument) -> Encodable?
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
