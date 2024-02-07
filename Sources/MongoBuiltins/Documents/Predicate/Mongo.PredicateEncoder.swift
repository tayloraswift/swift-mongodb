import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct PredicateEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<Mongo.AnyKeyPath>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<Mongo.AnyKeyPath>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.PredicateEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var type:BSON.AnyType { .document }
}

extension Mongo.PredicateEncoder
{
    //  Note: `@_disfavoredOverload` prevents a compiler crash due to the
    //  ``_MongoExpressionRestrictedEncodable``-gated diagnostic subscript.
    @_disfavoredOverload
    @inlinable public
    subscript<Encodable>(path:Mongo.AnyKeyPath) -> Encodable? where Encodable:BSONEncodable
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: path])
        }
    }

    /// Encodes a ``PredicateOperator``.
    ///
    /// This does not require [`@_disfavoredOverload`](), because
    /// ``PredicateOperator`` has no subscripts that accept string
    /// literals, so it will never conflict with ``BSON.Document``.
    @inlinable public
    subscript(path:Mongo.AnyKeyPath, yield:(inout Mongo.PredicateOperatorEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.PredicateOperatorEncoder.self])
        }
    }

    /// Encodes a nested ``PredicateDocument``.
    @inlinable public
    subscript(path:Mongo.AnyKeyPath, yield:(inout Mongo.PredicateEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.PredicateEncoder.self])
        }
    }

    @available(*, deprecated, message: "Use the functional subscript instead.")
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Mongo.PredicateOperator?
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: path.stem])
        }
    }
    @available(*, deprecated, message: "Use the functional subscript instead.")
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Mongo.PredicateDocument?
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: path.stem])
        }
    }
}
extension Mongo.PredicateEncoder
{
    @available(*, deprecated, message: """
        You cannot use expressions at the top-level of a predicate document, \
        even in a '$match' stage of an aggregation pipeline.
        """)
    public
    subscript<Expression>(path:Mongo.AnyKeyPath) -> Expression?
        where Expression:_MongoExpressionRestrictedEncodable
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: path.stem])
        }
    }
}
extension Mongo.PredicateEncoder
{
    @frozen public
    enum Branch:String, Hashable, Sendable
    {
        case and    = "$and"
        case nor    = "$nor"
        case or     = "$or"
    }

    @inlinable public
    subscript(key:Branch, yield:(inout Mongo.PredicateListEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.PredicateListEncoder.self])
        }
    }

    @available(*, deprecated, message: "Use the functional subscript instead.")
    @inlinable public
    subscript(key:Branch) -> Mongo.PredicateList?
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
    @available(*, deprecated)
    @inlinable public
    subscript(key:Branch) -> [Mongo.PredicateDocument]
    {
        get { [ ] }
        set (value)
        {
            value.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.PredicateEncoder
{
    @frozen public
    enum Comment:String, Hashable, Sendable
    {
        case comment = "$comment"
    }

    @inlinable public
    subscript<Encodable>(key:Comment) -> Encodable? where Encodable:BSONEncodable
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.PredicateEncoder
{
    @frozen public
    enum Expr:String, Hashable, Sendable
    {
        case expr = "$expr"
    }

    @inlinable public
    subscript(key:Expr, yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.ExpressionEncoder.self])
        }
    }

    @inlinable public
    subscript<Encodable>(key:Expr) -> Encodable? where Encodable:BSONEncodable
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }

    @available(*, deprecated, message: "Use the functional subscript instead.")
    @inlinable public
    subscript(key:Expr) -> Mongo.Expression?
    {
        get { nil }
        set (value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
