import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct DeleteStatement<Effect>:BSONRepresentable, BSONDSL, Sendable
        where Effect:MongoWriteEffect
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
extension Mongo.DeleteStatement:BSONDecodable
{
}
extension Mongo.DeleteStatement:BSONEncodable
{
}
extension Mongo.DeleteStatement
{
    @inlinable public
    subscript(key:Limit) -> Effect.DeletePlurality?
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
extension Mongo.DeleteStatement
{
    @inlinable public
    subscript(key:Q) -> Mongo.PredicateDocument?
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
    subscript(key:Hint) -> String?
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
    subscript(key:Hint) -> Mongo.SortDocument?
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
