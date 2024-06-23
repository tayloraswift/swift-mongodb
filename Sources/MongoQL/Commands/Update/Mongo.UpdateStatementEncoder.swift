import BSON

extension Mongo
{
    @frozen public
    struct UpdateStatementEncoder<Effect>:Sendable where Effect:Mongo.WriteEffect
    {
        @usableFromInline internal
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable public
        init(_ output:consuming BSON.Output)
        {
            self.bson = .init(output)
        }
    }
}
extension Mongo.UpdateStatementEncoder:BSON.Encoder
{
    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}
extension Mongo.UpdateStatementEncoder
{
    @frozen public
    enum Multi:String, Hashable, Sendable
    {
        case multi
    }

    @inlinable public
    subscript(key:Multi) -> Effect.UpdatePlurality?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.UpdateStatementEncoder
{
    @frozen public
    enum C:String, Hashable, Sendable
    {
        case c
    }

    @inlinable public
    subscript(key:C, yield:(inout Mongo.LetEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.LetEncoder.self])
        }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(key:C) -> Mongo.LetDocument?
    {
        nil
    }
}
extension Mongo.UpdateStatementEncoder
{
    @frozen public
    enum Q:String, Hashable, Sendable
    {
        case q
    }

    @inlinable public
    subscript(key:Q) -> Mongo.PredicateDocument?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }

    @inlinable public
    subscript(key:Q, yield:(inout Mongo.PredicateEncoder) -> () = { _ in }) -> Void
    {
        mutating
        get { yield(&self.bson[with: key][as: Mongo.PredicateEncoder.self]) }
    }
}
extension Mongo.UpdateStatementEncoder
{
    @frozen public
    enum U:String, Hashable, Sendable
    {
        case u
    }

    @inlinable public
    subscript(key:U, yield:(inout Mongo.UpdateEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self.bson[with: key][as: Mongo.UpdateEncoder.self]) }
    }

    @inlinable public
    subscript(key:U, yield:(inout Mongo.PipelineEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self.bson[with: key][as: Mongo.PipelineEncoder.self]) }
    }

    @inlinable public
    subscript<Replacement>(key:U) -> Replacement? where Replacement:BSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.UpdateStatementEncoder
{
    @frozen public
    enum ArrayFilters:String, Hashable, Sendable
    {
        case arrayFilters
    }

    @inlinable public
    subscript(key:ArrayFilters, yield:(inout Mongo.PredicateListEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self.bson[with: key][as: Mongo.PredicateListEncoder.self]) }
    }
    @inlinable public
    subscript(key:ArrayFilters) -> Mongo.PredicateList?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }

    @inlinable public
    subscript(key:ArrayFilters) -> [Mongo.PredicateDocument]
    {
        get { [] }
        set (value) { value.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.UpdateStatementEncoder
{
    @frozen public
    enum Collation:String, Hashable, Sendable
    {
        case collation
    }

    @inlinable public
    subscript(key:Collation) -> Mongo.Collation?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.UpdateStatementEncoder
{
    @frozen public
    enum Hint:String, Hashable, Sendable
    {
        case hint
    }

    @inlinable public
    subscript(key:Hint) -> String?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }

    @inlinable public
    subscript(key:Hint) -> Mongo.SortDocument?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.UpdateStatementEncoder
{
    @frozen public
    enum Upsert:String, Hashable, Sendable
    {
        case upsert
    }

    @inlinable public
    subscript(key:Upsert) -> Bool?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
