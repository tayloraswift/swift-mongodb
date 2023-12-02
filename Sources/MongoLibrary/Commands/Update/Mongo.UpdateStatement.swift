import BSON
import MongoQL

extension Mongo
{
    @frozen public
    struct UpdateStatement<Effect>:MongoDocumentDSL, Sendable where Effect:MongoWriteEffect
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
extension Mongo.UpdateStatement
{
    @inlinable public
    subscript(key:Multi) -> Effect.UpdatePlurality?
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
extension Mongo.UpdateStatement
{
    @inlinable public
    subscript(key:C) -> Mongo.LetDocument?
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
    subscript(key:U) -> Mongo.UpdateDocument?
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
    subscript(key:U) -> Mongo.Pipeline?
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
    subscript<Replacement>(key:U) -> Replacement?
        where Replacement:BSONEncodable
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
    subscript(key:ArrayFilters) -> Mongo.PredicateList?
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
    subscript(key:ArrayFilters) -> [Mongo.PredicateDocument]
    {
        get
        {
            []
        }
        set(value)
        {
            self.bson.append(key, value)
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

    @inlinable public
    subscript(key:Upsert) -> Bool?
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
