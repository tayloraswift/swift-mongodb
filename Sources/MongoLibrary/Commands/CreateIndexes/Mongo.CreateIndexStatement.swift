import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct CreateIndexStatement:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.CreateIndexStatement:BSONDecodable
{
}
extension Mongo.CreateIndexStatement:BSONEncodable
{
}
extension Mongo.CreateIndexStatement
{
    @inlinable public
    subscript(key:Collation) -> Mongo.Collation?
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

    @inlinable public
    subscript(key:Flag) -> Bool?
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

    @inlinable public
    subscript(key:Key) -> Mongo.SortDocument?
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

    @available(*, unavailable, message: "unimplemented")
    @inlinable public
    subscript(key:Language) -> Never?
    {
        nil
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
            self.bson.push(key, value)
        }
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
            self.bson.push(key, value)
        }
    }

    @inlinable public
    subscript(key:WildcardProjection) -> Mongo.ProjectionDocument?
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
