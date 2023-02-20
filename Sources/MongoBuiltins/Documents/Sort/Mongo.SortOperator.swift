import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct SortOperator:Sendable
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
extension Mongo.SortOperator:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.SortOperator:BSONEncodable
{
}
extension Mongo.SortOperator:BSONDecodable
{
}

extension Mongo.SortOperator
{
    @inlinable public
    subscript(key:Meta) -> Metadata?
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
