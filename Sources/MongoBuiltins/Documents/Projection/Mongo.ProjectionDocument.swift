import BSONEncoding
import MongoSchema

extension Mongo
{
    @frozen public
    struct ProjectionDocument:MongoDocumentDSL, Sendable
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
extension Mongo.ProjectionDocument
{
    /// Encodes a ``ProjectionOperator``.
    ///
    /// This does not require [`@_disfavoredOverload`](), because
    /// ``ProjectionOperator`` has no subscripts that accept string
    /// literals, so it will never conflict with ``BSON.Document``.
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Mongo.ProjectionOperator?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
    @inlinable public
    subscript<Encodable>(path:Mongo.KeyPath) -> Encodable? where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson.push(path.stem, value)
        }
    }
}
