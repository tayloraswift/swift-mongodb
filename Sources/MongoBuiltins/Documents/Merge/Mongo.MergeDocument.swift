import BSON
import MongoABI

extension Mongo
{
    @frozen public
    struct MergeDocument:Mongo.EncodableDocument, Sendable
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
extension Mongo.MergeDocument
{
    @inlinable public
    subscript(key:Into) -> Mongo.Collection?
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
    subscript(key:Into) -> Mongo.Namespaced<Mongo.Collection>?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.document.encode(to: &self.bson[with: key])
        }
    }

    @inlinable public
    subscript(key:On) -> Mongo.AnyKeyPath?
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.stem.encode(to: &self.bson[with: key])
        }
    }
    @inlinable public
    subscript(key:On) -> [BSON.Key]?
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
    subscript(key:Let, yield:(inout Mongo.LetEncoder) -> ()) -> Void
    {
        mutating get
        {
            yield(&self.bson[with: key][as: Mongo.LetEncoder.self])
        }
    }

    @available(*, unavailable)
    @inlinable public
    subscript(key:Let) -> Mongo.LetDocument?
    {
        nil
    }

    @inlinable public
    subscript(key:WhenMatched) -> Mongo.Pipeline?
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
    subscript(key:WhenMatched) -> Mongo.MergeUpdateMode?
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
    subscript(key:WhenNotMatched) -> Mongo.MergeInsertMode?
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
