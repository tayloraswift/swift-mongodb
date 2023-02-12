import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct CurrentOperationDocument:Sendable
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
extension Mongo.CurrentOperationDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
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
            self.fields[pushing: key] = value
        }
    }
}
