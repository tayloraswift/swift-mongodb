import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct LookupDocument:Mongo.EncodableDocument, Sendable
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
    subscript(key:Field) -> Mongo.AnyKeyPath?
    {
        get
        {
            nil
        }
        set(value)
        {
            //  Value does not include leading dollar sign!
            value?.stem.encode(to: &self.bson[with: key])
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
            value?.encode(to: &self.bson[with: key])
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
            value?.encode(to: &self.bson[with: key])
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
            value?.encode(to: &self.bson[with: key])
        }
    }
}
