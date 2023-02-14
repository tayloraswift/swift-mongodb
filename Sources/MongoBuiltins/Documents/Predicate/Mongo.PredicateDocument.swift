import BSONEncoding
import BSONDecoding

extension Mongo
{
    @frozen public
    struct PredicateDocument:Sendable
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
extension Mongo.PredicateDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
    /// @import(BSONDSL)
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
            self.document[key] = value
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
            self.document[key] = value
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
            self.document[key] = value
        }
    }
}
extension Mongo.PredicateDocument
{
    @inlinable public
    subscript(key:Branch) -> BSON.List<Self>?
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
    @inlinable public
    subscript(key:Branch) -> [Self]
    {
        get
        {
            []
        }
        set(value)
        {
            self.document[pushing: key] = value
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
            self.document[pushing: key] = value
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
            self.document[pushing: key] = value
        }
    }
}
