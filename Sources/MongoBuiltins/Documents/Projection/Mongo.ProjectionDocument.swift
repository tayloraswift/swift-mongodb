import BSONEncoding

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
    subscript(key:BSON.Key) -> Mongo.ProjectionOperator?
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
    subscript<Encodable>(key:BSON.Key) -> Encodable? where Encodable:BSONEncodable
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
