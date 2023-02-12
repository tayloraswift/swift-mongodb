import BSONEncoding

extension Mongo
{
    @frozen public
    struct ReduceDocument:Sendable
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
extension Mongo.ReduceDocument:BSONDSL
{
    @inlinable public
    var bytes:[UInt8]
    {
        self.fields.bytes
    }
}
extension Mongo.ReduceDocument:BSONEncodable
{
}
extension Mongo.ReduceDocument
{
    @inlinable public
    subscript<Encodable>(key:Argument) -> Encodable?
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
