import BSONDecoding
import BSONEncoding
import MongoDSL

extension Mongo
{
    /// Not to be confused with ``FilterDocument``.
    @frozen public
    struct PredicateDocument:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.PredicateDocument:BSONDecodable
{
}
extension Mongo.PredicateDocument:BSONEncodable
{
}

extension Mongo.PredicateDocument
{
    /// Encodes an ``Operator``.
    ///
    /// This does not require [`@_disfavoredOverload`](), because
    /// ``Operator`` has no ``String``-keyed subscripts, so it will
    /// never conflict with ``BSON.Document``.
    @inlinable public
    subscript(key:String) -> Mongo.PredicateOperator?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson[key] = value
        }
    }
    @inlinable public
    subscript(key:String) -> Self?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson[key] = value
        }
    }
    @inlinable public
    subscript<Encodable>(key:String) -> Encodable? where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            self.bson[key] = value
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
    subscript<Encodable>(key:Expr) -> Encodable? where Encodable:MongoExpressionEncodable
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
