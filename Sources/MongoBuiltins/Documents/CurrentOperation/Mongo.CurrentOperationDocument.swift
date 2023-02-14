import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct CurrentOperationDocument:Sendable
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
extension Mongo.CurrentOperationDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
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
            self.document[pushing: key] = value
        }
    }
}
