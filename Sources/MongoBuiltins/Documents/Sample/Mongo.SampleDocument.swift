import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct SampleDocument:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.SampleDocument:BSONEncodable
{
}
extension Mongo.SampleDocument:BSONDecodable
{
}

extension Mongo.SampleDocument
{
    @inlinable public
    subscript(key:Size) -> Int?
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
