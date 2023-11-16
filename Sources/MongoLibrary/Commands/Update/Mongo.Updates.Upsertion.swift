import BSONDecoding
import MongoDriver

extension Mongo.Updates
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
extension Mongo.Updates.Upsertion:Identifiable where ID:Hashable
{
}
extension Mongo.Updates.Upsertion:Equatable where ID:Equatable
{
}
extension Mongo.Updates.Upsertion:Sendable where ID:Sendable
{
}
extension Mongo.Updates.Upsertion:
    BSONDocumentDecodable,
    BSONDocumentViewDecodable,
    BSONDecodable where ID:BSONDecodable
{
    public
    enum CodingKey:String, Sendable
    {
        case index
        case id = "_id"
    }
    @inlinable public
    init(bson:BSON.DocumentDecoder<CodingKey, some RandomAccessCollection<UInt8>>) throws
    {
        self.init(index: try bson[.index].decode(), id: try bson[.id].decode())
    }
}
