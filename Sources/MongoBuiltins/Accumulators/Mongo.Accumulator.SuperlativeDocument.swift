import BSONDecoding
import BSONEncoding

extension Mongo.Accumulator
{
    @frozen public
    struct SuperlativeDocument:Sendable
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
extension Mongo.Accumulator.SuperlativeDocument:BSONStream
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.document.bytes
    }
}
extension Mongo.Accumulator.SuperlativeDocument:BSONDecodable
{
}
extension Mongo.Accumulator.SuperlativeDocument:BSONEncodable
{
}

extension Mongo.Accumulator.SuperlativeDocument
{
    @inlinable public
    subscript<Encodable>(key:Mongo.SortDocument.Input) -> Encodable?
        where Encodable:MongoExpressionEncodable
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
    @inlinable public
    subscript<Encodable>(key:Mongo.SortDocument.Count) -> Encodable?
        where Encodable:MongoExpressionEncodable
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
