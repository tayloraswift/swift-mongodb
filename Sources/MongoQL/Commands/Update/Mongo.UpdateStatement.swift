import BSON

extension Mongo
{
    @frozen public
    struct UpdateStatement<Effect>:Sendable where Effect:Mongo.WriteEffect
    {
        @usableFromInline internal
        var bson:BSON.DocumentEncoder<BSON.Key>

        @inlinable public
        init(_ output:consuming BSON.Output<[UInt8]>)
        {
            self.bson = .init(output)
        }
    }
}
extension Mongo.UpdateStatement:BSON.Encoder
{
    @inlinable public consuming
    func move() -> BSON.Output<[UInt8]> { self.bson.move() }

    @inlinable public static
    var type:BSON.AnyType { .document }
}
extension Mongo.UpdateStatement
{
    @inlinable public
    subscript(key:Multi) -> Effect.UpdatePlurality?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.UpdateStatement
{
    @inlinable public
    subscript(key:C) -> Mongo.LetDocument?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }

    @inlinable public
    subscript(key:Q) -> Mongo.PredicateDocument?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }

    @inlinable public
    subscript(key:U) -> Mongo.UpdateDocument?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }

    @inlinable public
    subscript(key:U, yield:(inout Mongo.PipelineEncoder) -> ()) -> Void
    {
        mutating
        get { yield(&self.bson[with: key][as: Mongo.PipelineEncoder.self]) }
    }
    @inlinable public
    subscript(key:U) -> Mongo.Pipeline?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }

    @inlinable public
    subscript<Replacement>(key:U) -> Replacement?
        where Replacement:BSONEncodable
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
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

    @inlinable public
    subscript(key:Collation) -> Mongo.Collation?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
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

    @inlinable public
    subscript(key:Upsert) -> Bool?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
