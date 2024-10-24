import BSON
import MongoQL

struct Ape:Equatable, Hashable
{
    let id:Int
    let name:String
    let food:Food?

    init(id:Int, name:String, food:Food?)
    {
        self.id = id
        self.name = name
        self.food = food
    }
}
extension Ape:Mongo.MasterCodingModel
{
    enum CodingKey:String, Sendable
    {
        case id = "_id"
        case name
        case food
    }
}
extension Ape:BSONDocumentEncodable
{
    func encode(to bson:inout BSON.DocumentEncoder<CodingKey>)
    {
        bson[.id] = self.id
        bson[.name] = self.name
        bson[.food] = self.food
    }
}
extension Ape:BSONDocumentDecodable
{
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(
            id: try bson[.id].decode(),
            name: try bson[.name].decode(),
            food: try bson[.food]?.decode())
    }
}
