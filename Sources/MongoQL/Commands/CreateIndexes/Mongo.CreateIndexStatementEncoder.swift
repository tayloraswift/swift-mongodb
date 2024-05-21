import BSON

extension Mongo
{
    @frozen public
    struct CreateIndexStatementEncoder:Sendable
    {
        @usableFromInline
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable internal
        init(bson:BSON.DocumentEncoder<BSON.Key>)
        {
            self.bson = bson
        }
    }
}
extension Mongo.CreateIndexStatementEncoder:BSON.Encoder
{
    @inlinable public
    init(_ output:consuming BSON.Output)
    {
        self.init(bson: .init(output))
    }

    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}

extension Mongo.CreateIndexStatementEncoder
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }

    @inlinable public
    subscript(key:Collation) -> Mongo.Collation?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.CreateIndexStatementEncoder
{
    @frozen public
    enum Flag:String, Hashable, Sendable
    {
        case unique
        case sparse
        case hidden
    }

    @inlinable public
    subscript(key:Flag) -> Bool?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.CreateIndexStatementEncoder
{
    @frozen public
    enum Key:String, Hashable, Sendable
    {
        case key
    }

    @inlinable public
    subscript(key:Key) -> Mongo.SortDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.CreateIndexStatementEncoder
{
    @frozen public
    enum Language:String, Hashable, Sendable
    {
        case languageDefault = "default_language"
        case languageOverride = "language_override"

        @available(*, unavailable, renamed: "languageDefault")
        public static
        var default_language:Self { .languageDefault }

        @available(*, unavailable, renamed: "languageOverride")
        public static
        var language_override:Self { .languageOverride }
    }

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:Language) -> Never?
    {
        nil
    }
}
extension Mongo.CreateIndexStatementEncoder
{
    @frozen public
    enum Name:String, Hashable, Sendable
    {
        case name
    }

    @inlinable public
    subscript(key:Name) -> String?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.CreateIndexStatementEncoder
{
    @frozen public
    enum PartialFilterExpression:String, Hashable, Sendable
    {
        case partialFilterExpression
    }

    //  TODO: this is undertyped; only some of the query operators are allowed here.
    @inlinable public
    subscript(key:PartialFilterExpression) -> Mongo.PredicateDocument?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.CreateIndexStatementEncoder
{
    @frozen public
    enum WildcardProjection:String, Hashable, Sendable
    {
        case wildcardProjection
    }

    /// Encodes a projection document.
    @inlinable public
    subscript(key:WildcardProjection, yield:(inout Mongo.ProjectionEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.ProjectionEncoder.self])
        }
    }

    /// Encodes a projection document from a model type.
    @inlinable public
    subscript<ProjectionDocument>(key:WildcardProjection) -> ProjectionDocument?
        where ProjectionDocument:Mongo.ProjectionEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key][as: Mongo.ProjectionEncoder.self])
        }
    }
}
