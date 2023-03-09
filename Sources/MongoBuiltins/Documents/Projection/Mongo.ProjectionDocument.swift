import BSONEncoding
import BSONDecoding

extension Mongo
{
    @frozen public
    struct ProjectionDocument:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.ProjectionDocument:BSONEncodable
{
}
extension Mongo.ProjectionDocument:BSONDecodable
{
}
extension Mongo.ProjectionDocument
{
    /// Encodes an ``Operator``.
    ///
    /// This does not require [`@_disfavoredOverload`](), because
    /// ``Operator`` has no ``String``-keyed subscripts, so it will
    /// never conflict with ``BSON.Document``.
    @inlinable public
    subscript(key:String) -> Mongo.ProjectionOperator?
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
    subscript<Encodable>(key:String) -> Encodable? where Encodable:MongoExpressionEncodable
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
