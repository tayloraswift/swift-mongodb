import BSONDecoding
import MongoDriver

extension Mongo.UpdateResponse
{
    public
    struct Upsertion
    {
        public
        let index:Int
        public
        let id:ID

        public
        init(index:Int, id:ID)
        {
            self.index = index
            self.id = id
        }
    }
}
extension Mongo.UpdateResponse.Upsertion:Identifiable where ID:Hashable
{
}
extension Mongo.UpdateResponse.Upsertion:Equatable where ID:Equatable
{
}
extension Mongo.UpdateResponse.Upsertion:Sendable where ID:Sendable
{
}
extension Mongo.UpdateResponse.Upsertion:BSONDocumentDecodable
{
    public
    enum CodingKeys:String
    {
        case index
        case id = "_id"
    }
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKeys, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(index: try bson[.index].decode(), id: try bson[.id].decode())
    }
}
