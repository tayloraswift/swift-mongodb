import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct FacetDocument:Sendable
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
extension Mongo.FacetDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.FacetDocument:BSONEncodable
{
}
extension Mongo.FacetDocument:BSONDecodable
{
}

extension Mongo.FacetDocument
{
    @inlinable public
    subscript(key:String) -> Mongo.Pipeline?
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
