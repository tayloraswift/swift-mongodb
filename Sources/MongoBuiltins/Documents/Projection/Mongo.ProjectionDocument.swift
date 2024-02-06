import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct ProjectionDocument:Mongo.EncodableDocument, Sendable
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
    subscript(path:Mongo.AnyKeyPath) -> Mongo.ProjectionOperator?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path.stem])
        }
    }
    @inlinable public
    subscript<Encodable>(path:Mongo.AnyKeyPath) -> Encodable? where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path.stem])
        }
    }
}
