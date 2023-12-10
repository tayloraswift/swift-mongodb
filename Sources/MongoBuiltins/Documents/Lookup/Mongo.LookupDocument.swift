import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct LookupDocument:MongoDocumentDSL, Sendable
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
extension Mongo.LookupDocument
{
    @inlinable public
    subscript(key:Field) -> Mongo.KeyPath?
    {
        get
        {
            nil
        }
        set(value)
        {
            //  Value does not include leading dollar sign!
            self.bson.push(key, value?.stem)
        }
    }
    @inlinable public
    subscript(key:From) -> Mongo.Collection?
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
    subscript(key:Let) -> Mongo.LetDocument?
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
    subscript(key:Pipeline) -> Mongo.Pipeline?
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
