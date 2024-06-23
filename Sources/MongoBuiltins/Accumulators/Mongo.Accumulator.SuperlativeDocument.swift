import BSON

extension Mongo.Accumulator
{
    @frozen public
    struct SuperlativeDocument:Mongo.EncodableDocument, Sendable
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
extension Mongo.Accumulator.SuperlativeDocument
{
    @frozen public
    enum Input:String, Sendable
    {
        case input
    }

    @inlinable public
    subscript<Encodable>(key:Input) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
extension Mongo.Accumulator.SuperlativeDocument
{
    @inlinable public
    subscript<Encodable>(key:Mongo.Accumulator.N) -> Encodable?
        where Encodable:BSONEncodable
    {
        get
        {
            nil
        }
        set(value)
        {
            value?.encode(to: &self.bson[with: key])
        }
    }
}
