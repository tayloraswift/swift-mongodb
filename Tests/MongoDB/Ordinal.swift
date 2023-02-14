import BSONDecoding
import BSONEncoding

struct Ordinal:Hashable, Sendable
{
    let id:Int
    let value:Int64
}
extension Ordinal:BSONEncodable, BSONDocumentEncodable
{
    func encode(to bson:inout BSON.Document)
    {
        bson["_id"] = self.id
        bson["ordinal"] = self.value
    }
}
extension Ordinal:BSONDecodable, BSONDictionaryDecodable
{
    init(bson:BSON.Dictionary<some RandomAccessCollection<UInt8>>) throws
    {
        self.init(id: try bson["_id"].decode(to: Int.self),
            value: try bson["ordinal"].decode(to: Int64.self))
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
