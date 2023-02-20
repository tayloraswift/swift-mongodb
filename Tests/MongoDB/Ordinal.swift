import BSONDecoding
import BSONEncoding

struct Ordinal:Hashable, Sendable
{
    let id:Int
    let value:Int64
}
extension Ordinal
{
    enum CodingKeys:String
    {
        case id = "_id"
        case ordinal
    }
}
extension Ordinal:BSONEncodable, BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKeys>)
    {
        bson[.id] = self.id
        bson[.ordinal] = self.value
    }
}
extension Ordinal:BSONDecodable, BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(to: Int.self),
            value: try bson[.ordinal].decode(to: Int64.self))
    }
}
extension Ordinal:CustomStringConvertible
{
    var description:String
    {
        """
        {_id: \(self.id), ordinal: \(self.value)}
        """
    }
}
