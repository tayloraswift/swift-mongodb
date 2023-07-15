import BSONDecoding
import BSONEncoding

struct Record<Value>:Hashable, Sendable
    where Value:Hashable & Sendable & BSONDecodable & BSONEncodable
{
    let id:Int
    let value:Value
}
extension Record
{
    enum CodingKey:String
    {
        case id = "_id"
        case value
    }
}
extension Record:BSONEncodable, BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.value] = self.value
    }
}
extension Record:BSONDecodable, BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson[.id].decode(to: Int.self),
            value: try bson[.value].decode(to: Value.self))
    }
}
extension Record:CustomStringConvertible
{
    var description:String
    {
        """
        {_id: \(self.id), value: \(self.value)}
        """
    }
}
