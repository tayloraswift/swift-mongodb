import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct MergeDocument:Sendable
    {
        public
        var document:BSON.Document

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.document = .init(bytes: bytes)
        }
    }
}
extension Mongo.MergeDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.MergeDocument:BSONEncodable
{
}
extension Mongo.MergeDocument:BSONDecodable
{
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
            self.document[pushing: key] = value
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
            self.document[pushing: key] = value?.document
        }
    }

    @inlinable public
    subscript(key:On) -> String?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document[pushing: key] = value
        }
    }
    @inlinable public
    subscript(key:On) -> [String]?
    {
        get
        {
            nil
        }
        set(value)
        {
            self.document[pushing: key] = value
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
            self.document[pushing: key] = value
        }
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
            self.document[pushing: key] = value
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
            self.document[pushing: key] = value
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
            self.document[pushing: key] = value
        }
    }
}
