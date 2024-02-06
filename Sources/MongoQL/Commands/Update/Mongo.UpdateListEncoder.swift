import BSON

extension Mongo
{
    @available(*, deprecated, renamed: "UpdateListEncoder")
    public
    typealias UpdateEncoder = UpdateListEncoder

    @frozen public
    struct UpdateListEncoder<Effect> where Effect:Mongo.WriteEffect
    {
        @usableFromInline internal
        var output:BSON.Output

        @inlinable internal
        init()
        {
            self.output = .init(preallocated: [])
        }
    }
}
extension Mongo.UpdateListEncoder
{
    @inlinable internal consuming
    func move() -> BSON.Output { self.output }
}
extension Mongo.UpdateListEncoder
{
    @inlinable public mutating
    func callAsFunction<T>(
        with yield:(inout Mongo.UpdateStatementEncoder<Effect>) throws -> T) rethrows -> T
    {
        try yield(&self.output[
            as: Mongo.UpdateStatementEncoder<Effect>.self,
            in: BSON.DocumentFrame.self])
    }
}
extension Mongo.UpdateListEncoder
{
    /// A shorthand for ``update(_:upsert:)`` with `upsert` set to false.
    @inlinable public mutating
    func replace(
        _ element:some BSONDocumentEncodable & Identifiable<some BSONEncodable>)
    {
        self.update(element, upsert: false)
    }
    /// A shorthand for ``update(_:upsert:)`` with `upsert` set to true.
    @inlinable public mutating
    func upsert(
        _ element:some BSONDocumentEncodable & Identifiable<some BSONEncodable>)
    {
        self.update(element, upsert: true)
    }
    /// Upserts or replaces a document by its ``Identifiable/id``.
    @inlinable mutating
    func update(
        _ element:some BSONDocumentEncodable & Identifiable<some BSONEncodable>,
        upsert:Bool)
    {
        self
        {
            $0[.upsert] = upsert
            $0[.q] = .init { $0["_id"] = element.id }
            $0[.u] = element
        }
    }
}
