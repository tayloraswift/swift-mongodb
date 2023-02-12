import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct MergeDocument:Sendable
    {
        public
        var fields:BSON.Fields

        @inlinable public
        init(bytes:[UInt8] = [])
        {
            self.fields = .init(bytes: bytes)
        }
    }
}
extension Mongo.MergeDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
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
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value?.document
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
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value
        }
    }
}
