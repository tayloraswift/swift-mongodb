import BSON

extension FindAndModify
{
    struct Ruler:Equatable, Hashable, BSONDocumentDecodable, BSONDocumentEncodable
    {
        let id:String
        let party:String
        let since:Int

        init(id:String,
            party:String,
            since:Int)
        {
            self.id = id
            self.party = party
            self.since = since
        }

        enum CodingKey:String, Sendable
        {
            case id = "_id"
            case party
            case since
        }

        init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>)
            throws
        {
            self.init(id: try bson[.id].decode(),
                party: try bson[.party].decode(),
                since: try bson[.since].decode())
        }

        func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
        {
            bson[.id] = self.id
            bson[.party] = self.party
            bson[.since] = self.since
        }
    }
}
