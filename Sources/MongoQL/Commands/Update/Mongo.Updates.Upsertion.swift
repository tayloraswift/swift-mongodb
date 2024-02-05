import BSON

extension Mongo.Updates
{
    public
    struct Upsertion:Sendable
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
    init(bson:BSON.DocumentDecoder<CodingKey>) throws
    {
        self.init(index: try bson[.index].decode(), id: try bson[.id].decode())
    }
}
