import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct ProjectionEncoder<CodingKey>:Sendable where CodingKey:RawRepresentable<String>
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<CodingKey>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<CodingKey>)
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
    subscript(path:CodingKey) -> Int?
    {
        get { nil }
        set {     }
    }

    @inlinable public
    subscript(path:CodingKey) -> Bool?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: path]) }
    }

    /// Encodes a nested projection document.
    @inlinable public
    subscript<NestedKey>(path:CodingKey,
        using _:NestedKey.Type = NestedKey.self,
        yield:(inout Mongo.ProjectionEncoder<NestedKey>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.ProjectionEncoder<NestedKey>.self])
        }
    }

    /// Encodes a nested projection document from a model type.
    @inlinable public
    subscript<ProjectionDocument>(path:CodingKey) -> ProjectionDocument?
        where ProjectionDocument:Mongo.ProjectionEncodable
    {
        get { nil }
        set (value) { value.map { self[path, $0.encode(to:)] } }
    }

    /// Encodes a projection expression.
    @inlinable public
    subscript(path:CodingKey, yield:(inout Mongo.ExpressionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.ExpressionEncoder.self])
        }
    }

    /// Encodes a projection operator.
    @inlinable public
    subscript(path:CodingKey,
        yield:(inout Mongo.ProjectionOperatorEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: path][as: Mongo.ProjectionOperatorEncoder.self])
        }
    }

    /// Encodes a projection operator from a model type.
    @inlinable public
    subscript<Operator>(path:CodingKey) -> Operator?
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
