import BSON
import MongoABI

extension Mongo
{
    /// Not to be confused with ``PredicateDocument``.
    @frozen public
    struct FilterDocument:Mongo.EncodableDocument, Sendable
    {
        public
        var bson:BSON.Document

        @inlinable public
        init(_ bson:BSON.Document)
        {
            self.bson = bson
        }
    }
}
extension Mongo.FilterDocument
{
    @inlinable public static
    func `let`(_ variable:Mongo.Variable<some Any>,
        with populate:(inout Self) throws -> ()) rethrows -> Self
    {
        try .let(variable.name, with: populate)
    }
    @inlinable public static
    func `let`(_ variable:Mongo.Variable<Any>,
        with populate:(inout Self) throws -> ()) rethrows -> Self
    {
        try .let(variable.name, with: populate)
    }

    @inlinable internal static
    func `let`(_ variable:BSON.Key,
        with populate:(inout Self) throws -> ()) rethrows -> Self
    {
        var document:Self = .init(.init { $0["as"] = variable })
        try populate(&document)
        return document
    }
}
extension Mongo.FilterDocument
{
    @inlinable public
    subscript<Encodable>(key:Argument) -> Encodable?
        where Encodable:BSONEncodable
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
