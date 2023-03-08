import BSONDecoding
import BSONEncoding

extension Mongo
{
    @frozen public
    struct SortOperator:BSONRepresentable, BSONDSL, Sendable
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
            self.bson.push(key, value)
        }
    }
}
