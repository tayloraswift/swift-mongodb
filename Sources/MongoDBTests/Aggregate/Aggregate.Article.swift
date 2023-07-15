import BSONDecoding
import BSONEncoding

extension Aggregate
{
    struct Article:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
    {
        let id:BSON.Identifier
        let author:String
        let title:String
        let views:Int
        let tags:[String]

        init(id:BSON.Identifier,
            author:String,
            title:String,
            views:Int,
            tags:[String])
        {
            self.id = id
            self.author = author
            self.title = title
            self.views = views
            self.tags = tags
        }

        enum CodingKey:String
        {
            case id = "_id"
            case author
            case title
            case views
            case tags
        }

        init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>)
            throws
        {
            self.init(id: try bson[.id].decode(),
                author: try bson[.author].decode(),
                title: try bson[.title].decode(),
                views: try bson[.views].decode(),
                tags: try bson[.tags].decode())
        }

        func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
        {
            bson[.id] = self.id
            bson[.author] = self.author
            bson[.title] = self.title
            bson[.views] = self.views
            bson[.tags] = self.tags
        }
    }
}
