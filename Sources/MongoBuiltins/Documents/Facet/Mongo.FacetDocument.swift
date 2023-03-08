import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct FacetDocument:BSONRepresentable, BSONDSL, Sendable
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
            self.bson.push(key, value)
        }
    }
}
