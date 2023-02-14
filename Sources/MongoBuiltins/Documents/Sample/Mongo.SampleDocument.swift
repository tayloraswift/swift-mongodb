import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct SampleDocument:Sendable
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
extension Mongo.SampleDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
            self.document[pushing: key] = value
        }
    }
}
