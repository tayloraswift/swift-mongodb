import BSONDecoding
import BSONEncoding

extension Aggregate
{
    struct TagStats:Equatable, Hashable, BSONDocumentDecodable
    {
        let id:String
        let count:Int

        init(id:String, count:Int)
        {
            self.id = id
            self.count = count
        }

        enum CodingKey:String
        {
            case id = "_id"
            case count
        }

        init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>)
            throws
        {
            self.init(id: try bson[.id].decode(), count: try bson[.count].decode())
        }
    }
}
