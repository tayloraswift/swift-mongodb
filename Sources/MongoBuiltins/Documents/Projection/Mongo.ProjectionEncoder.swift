import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct ProjectionEncoder:Sendable
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
extension Mongo.ProjectionEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output) { self.init(bson: .init(output)) }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}

extension Mongo.ProjectionEncoder
{
    @available(*, unavailable, message: "Use the boolean subscript instead.")
    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Int?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path])
        }
    }

    @inlinable public
    subscript(path:Mongo.AnyKeyPath) -> Bool?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path])
        }
    }

    /// Encodes a nested projection document.
    @inlinable public
    subscript(path:Mongo.AnyKeyPath, yield:(inout Mongo.ProjectionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.ProjectionEncoder.self])
        }
    }

    /// Encodes a projection expression.
    @inlinable public
    subscript(path:Mongo.AnyKeyPath, yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.ExpressionEncoder.self])
        }
    }

    /// Encodes a projection operator.
    @inlinable public
    subscript(path:Mongo.AnyKeyPath,
        yield:(inout Mongo.ProjectionOperatorEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.ProjectionOperatorEncoder.self])
        }
    }

    /// Encodes a projection operator from a model type.
    @inlinable public
    subscript<Operator>(path:Mongo.AnyKeyPath) -> Operator?
        where Operator:Mongo.ProjectionOperatorEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: path][as: Mongo.ProjectionOperatorEncoder.self])
        }
    }
}
@available(*, deprecated)
extension Mongo.ProjectionEncoder
{
    /// Encodes a ``ProjectionOperator``.
    ///
    /// This does not require `@_disfavoredOverload`, because ``ProjectionOperator`` has no
    /// subscripts that accept string literals, so it will never conflict with
    /// ``BSON.Document``.
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
