import BSONEncoding
import BSONDecoding

extension Mongo
{
    @frozen public
    struct ProjectionDocument:Sendable
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
extension Mongo.ProjectionDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
    /// @import(BSONDSL)
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
            self.document[key] = value
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
            self.document[pushing: key] = value
        }
    }
}
