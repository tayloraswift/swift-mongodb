import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct UnionWithDocument:Sendable
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
extension Mongo.UnionWithDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.UnionWithDocument:BSONEncodable
{
}
extension Mongo.UnionWithDocument:BSONDecodable
{
}

extension Mongo.UnionWithDocument
{
    @inlinable public
    subscript(key:Collection) -> Mongo.Collection?
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
