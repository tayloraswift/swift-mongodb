import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct UnionWithDocument:Sendable
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
extension Mongo.UnionWithDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
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
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value
        }
    }
}
