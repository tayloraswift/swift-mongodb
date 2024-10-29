import BSON

extension Mongo
{
    @frozen public
    struct DeleteStatementEncoder<Effect> where Effect:Mongo.WriteEffect
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
extension Mongo.DeleteStatementEncoder:BSON.Encoder
{
    @inlinable public consuming
    func move() -> BSON.Output { self.bson.move() }

    @inlinable public static
    var frame:BSON.DocumentFrame { .document }
}
extension Mongo.DeleteStatementEncoder
{
    @frozen public
    enum Limit:String, Hashable, Sendable
    {
        case limit
    }

    @inlinable public
    subscript(key:Limit) -> Effect.DeletePlurality?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.DeleteStatementEncoder:Mongo.PredicateConfigurable
{
    @frozen public
    enum Q:String, Hashable, Sendable
    {
        case q
    }

    @inlinable public
    subscript(key:Q, yield:(inout Mongo.PredicateEncoder) -> () = { _ in }) -> Void
    {
        mutating
        get { yield(&self.bson[with: key][as: Mongo.PredicateEncoder.self]) }
    }
}
extension Mongo.DeleteStatementEncoder
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
extension Mongo.DeleteStatementEncoder:Mongo.HintableEncoder
{
    @frozen public
    enum Hint:String, Sendable
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
    subscript<IndexKey>(key:Hint,
        using _:IndexKey.Type = IndexKey.self,
        yield:(inout Mongo.SortEncoder<IndexKey>) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.SortEncoder<IndexKey>.self])
        }
    }
}