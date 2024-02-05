import BSON

extension Update
{
    struct Member:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
    {
        let id:Int
        let member:String
        let status:String
        let points:Int
        let comments:[String]
        let misc1:String?
        let misc2:String?

        init(id:Int,
            member:String,
            status:String,
            points:Int,
            comments:[String] = [],
            misc1:String? = nil,
            misc2:String? = nil)
        {
            self.id = id
            self.member = member
            self.status = status
            self.points = points
            self.comments = comments
            self.misc1 = misc1
            self.misc2 = misc2
        }

        enum CodingKey:String, Sendable
        {
            case id = "_id"
            case member
            case status
            case points
            case comments
            case misc1
            case misc2
        }

        init(bson:BSON.DocumentDecoder<CodingKey>) throws
        {
            self.init(id: try bson[.id].decode(),
                member: try bson[.member].decode(),
                status: try bson[.status].decode(),
                points: try bson[.points].decode(),
                comments: try bson[.comments]?.decode() ?? [],
                misc1: try bson[.misc1]?.decode(),
                misc2: try bson[.misc2]?.decode())
        }

        func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
        {
            bson[.id] = self.id
            bson[.member] = self.member
            bson[.status] = self.status
            bson[.points] = self.points
            bson[.comments] = self.comments.isEmpty ? nil : self.comments
            bson[.misc1] = self.misc1
            bson[.misc2] = self.misc2
        }
    }
}
