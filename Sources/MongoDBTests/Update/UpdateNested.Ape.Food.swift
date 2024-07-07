import BSON
import UnixTime

extension UpdateNested.Ape
{
    struct Food:Equatable, Hashable
    {
        let expires:UnixMillisecond?
        let type:String

        init(expires:UnixMillisecond?, type:String)
        {
            self.expires = expires
            self.type = type
        }
    }
}
extension UpdateNested.Ape.Food
{
    enum CodingKey:String, Sendable
    {
        case expires
        case type
    }
}
extension UpdateNested.Ape.Food:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.expires] = self.expires
        bson[.type] = self.type
    }
}
extension UpdateNested.Ape.Food:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            expires: try bson[.expires]?.decode(),
            type: try bson[.type].decode())
    }
}
