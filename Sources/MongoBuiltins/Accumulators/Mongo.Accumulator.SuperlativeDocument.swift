import BSONDecoding
import BSONEncoding

extension Mongo.Accumulator
{
    @frozen public
    struct SuperlativeDocument:Sendable
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
extension Mongo.Accumulator.SuperlativeDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
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
            self.fields[pushing: key] = value
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
            self.fields[pushing: key] = value
        }
    }
}
