import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct CurrentOperationDocument:BSONRepresentable, BSONDSL, Sendable
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
extension Mongo.CurrentOperationDocument:BSONEncodable
{
}
extension Mongo.CurrentOperationDocument:BSONDecodable
{
}

extension Mongo.CurrentOperationDocument
{
    @inlinable public
    subscript(key:Argument) -> Bool?
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
