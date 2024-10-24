import BSON
import MongoQL

struct Plan:Identifiable, Equatable, Sendable
{
    let id:Int
    var owner:String
    var level:String

    init(id:Int, owner:String, level:String)
    {
        self.id = id
        self.owner = owner
        self.level = level
    }
}
extension Plan:Mongo.MasterCodingModel
{
    enum CodingKey:String, BSONDecodable, Sendable
    {
        case id = "_id"
        case owner = "O"
        case level = "L"
    }
}
extension Plan:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.owner] = self.owner
        bson[.level] = self.level
    }
}
extension Plan:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(id: try bson[.id].decode(),
            owner: try bson[.owner].decode(),
            level: try bson[.level].decode())
    }
}
