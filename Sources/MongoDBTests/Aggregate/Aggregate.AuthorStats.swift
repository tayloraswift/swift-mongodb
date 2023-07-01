import BSONDecoding
import BSONEncoding

extension Aggregate
{
    struct AuthorStats:Equatable, Hashable, BSONDocumentDecodable
    {
        let id:String
        let views:Int

        init(id:String, views:Int)
        {
            self.id = id
            self.views = views
        }

        enum CodingKeys:String
        {
            case id = "_id"
            case views
        }

        init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>)
            throws
        {
            self.init(id: try bson[.id].decode(), views: try bson[.views].decode())
        }
    }
}
