import BSONEncoding
import BSONDecoding

extension Mongo
{
    @frozen public
    struct ProjectionDocument:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension Mongo.ProjectionDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
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
    /// never conflict with ``BSON.Fields``.
    @inlinable public
    subscript(key:String) -> Mongo.ProjectionOperator?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.fields[key] = value
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
            self.fields[pushing: key] = value
        }
    }
}
