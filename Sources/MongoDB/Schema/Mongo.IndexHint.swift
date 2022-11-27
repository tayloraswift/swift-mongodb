import BSONEncoding

extension Mongo
{
    @frozen public
    enum IndexHint:Sendable
    {
        case id(String)
        case index(BSON.Fields)
    }
}
extension Mongo.IndexHint:BSONEncodable
{
    public
    func encode(to field:inout BSON.Field)
    {
        switch self
        {
        case .id(let string):
            string.encode(to: &field)
        case .index(let fields):
            fields.encode(to: &field)
        }
    }
}
