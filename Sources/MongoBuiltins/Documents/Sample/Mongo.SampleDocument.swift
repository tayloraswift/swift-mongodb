import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct SampleDocument:Sendable
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
extension Mongo.SampleDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
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
            self.fields[pushing: key] = value
        }
    }
}
