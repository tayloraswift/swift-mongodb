import BSON

extension Mongo
{
    @frozen public
    struct ChangeTruncatedArray<Field>
    {
        public
        let field:Field
        public
        let newSize:Int

        @inlinable public
        init(field:Field, newSize:Int)
        {
            self.field = field
            self.newSize = newSize
        }
    }
}
extension Mongo.ChangeTruncatedArray:Sendable where Field:Sendable
{
}
extension Mongo.ChangeTruncatedArray:Equatable where Field:Equatable
{
}
extension Mongo.ChangeTruncatedArray:BSONDecodable, BSONDocumentDecodable
    where Field:BSONDecodable
{
    @frozen public
    enum CodingKey:String, Hashable, Sendable
    {
        case field
        case newSize
    }

    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(field: try bson[.field].decode(), newSize: try bson[.newSize].decode())
    }
}
