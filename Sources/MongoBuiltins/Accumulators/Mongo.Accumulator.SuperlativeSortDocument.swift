import BSONDecoding
import BSONEncoding

extension Mongo.Accumulator
{
    @frozen public
    struct SuperlativeSortDocument<Count>:Sendable
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
extension Mongo.Accumulator.SuperlativeSortDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.Accumulator.SuperlativeSortDocument:BSONDecodable
{
}
extension Mongo.Accumulator.SuperlativeSortDocument:BSONEncodable
{
}

extension Mongo.Accumulator.SuperlativeSortDocument
{
    @inlinable public
    subscript(key:Mongo.SortDocument.By) -> Mongo.SortDocument?
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
    subscript<Encodable>(key:Mongo.SortDocument.Output) -> Encodable?
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
extension Mongo.Accumulator.SuperlativeSortDocument<Mongo.SortDocument.Count>
{
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
