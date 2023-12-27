import BSON

extension Mongo
{
    @frozen public
    struct DeleteStatement<Effect> where Effect:Mongo.WriteEffect
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
extension Mongo.DeleteStatement:BSON.Encoder
{
    @inlinable public consuming
    func move() -> BSON.Output<[UInt8]> { self.bson.move() }

    @inlinable public static
    var type:BSON.AnyType { .document }
}
extension Mongo.DeleteStatement
{
    @inlinable public
    subscript(key:Limit) -> Effect.DeletePlurality?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
    }
}
extension Mongo.DeleteStatement
{
    @inlinable public
    subscript(key:Q) -> Mongo.PredicateDocument?
    {
        get { nil }
        set (value) { value?.encode(to: &self.bson[with: key]) }
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
}
