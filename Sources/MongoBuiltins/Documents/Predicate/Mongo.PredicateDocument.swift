import BSONEncoding
import MongoSchema

extension Mongo
{
    /// Not to be confused with ``FilterDocument``.
    @frozen public
    struct PredicateDocument:MongoDocumentDSL, Sendable
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
/// You can use an empty dictionary literal (`[:]`) to express an
/// unconditional predicate.
extension Mongo.PredicateDocument:ExpressibleByDictionaryLiteral
{
}
extension Mongo.PredicateDocument
{
    /// Encodes a ``PredicateOperator``.
    ///
    /// This does not require [`@_disfavoredOverload`](), because
    /// ``PredicateOperator`` has no subscripts that accept string
    /// literals, so it will never conflict with ``BSON.Document``.
    @inlinable public
    subscript(path:Mongo.KeyPath) -> Mongo.PredicateOperator?
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
    subscript(path:Mongo.KeyPath) -> Self?
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
extension Mongo.PredicateDocument
{
    @inlinable public
    subscript(key:Branch) -> Mongo.PredicateList?
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
    subscript(key:Branch) -> [Self]
    {
        get
        {
            []
        }
        set(value)
        {
            self.bson.append(key, value)
        }
    }
    @inlinable public
    subscript<Encodable>(key:Comment) -> Encodable? where Encodable:BSONEncodable
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
    subscript<Encodable>(key:Expr) -> Encodable? where Encodable:BSONEncodable
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
