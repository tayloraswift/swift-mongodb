import BSON

extension Mongo
{
    @frozen @usableFromInline
    struct CursorOptions<Stride> where Stride:BSONEncodable
    {
        @usableFromInline
        let batchSize:Stride

        @inlinable
        init(batchSize:Stride)
        {
            self.batchSize = batchSize
        }
    }
}
extension Mongo.CursorOptions:BSONDocumentEncodable
{
    @frozen @usableFromInline
    enum CodingKey:String, Sendable
    {
        case batchSize
    }

    @inlinable
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.batchSize] = self.batchSize
    }
}
