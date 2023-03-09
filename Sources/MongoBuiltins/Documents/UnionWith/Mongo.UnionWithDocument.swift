import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct UnionWithDocument:BSONRepresentable, BSONDSL, Sendable
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
