import BSONEncoding
import MongoExpressions

extension Mongo
{
    /// Not to be confused with ``PredicateDocument``.
    @frozen public
    struct FilterDocument:MongoDocumentDSL, Sendable
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
    func `let`(_ variable:some MongoExpressionVariable,
        with populate:(inout Self) throws -> ()) rethrows -> Self
    {
        try .let(variable.name, with: populate)
    }
    @inlinable public static
    func `let`(_ variable:String,
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
            self.bson.push(key, value)
        }
    }
}
