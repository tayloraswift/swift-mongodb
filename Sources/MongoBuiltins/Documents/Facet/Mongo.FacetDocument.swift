import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct FacetDocument:Sendable
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
extension Mongo.FacetDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
            self.document.push(key, value)
        }
    }
}
