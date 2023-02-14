import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct LookupDocument:Sendable
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
extension Mongo.LookupDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.LookupDocument:BSONEncodable
{
}
extension Mongo.LookupDocument:BSONDecodable
{
}

extension Mongo.LookupDocument
{
    @inlinable public
    subscript(key:Field) -> String?
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
    subscript(key:From) -> Mongo.Collection?
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
    subscript(key:Pipeline) -> Mongo.Pipeline?
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
