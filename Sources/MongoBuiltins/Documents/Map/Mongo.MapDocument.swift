import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct MapDocument:MongoDocumentDSL, Sendable
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
extension Mongo.MapDocument
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
extension Mongo.MapDocument
{
    @inlinable public
    subscript<Encodable>(key:Argument) -> Encodable? where Encodable:BSONEncodable
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
