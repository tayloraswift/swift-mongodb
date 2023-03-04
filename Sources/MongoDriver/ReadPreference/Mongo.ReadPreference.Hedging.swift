import BSONEncoding

extension Mongo.ReadPreference
{
    @frozen public
    enum Hedging:Hashable, Sendable
    {
        case enabled
        case disabled
    }
}
extension Mongo.ReadPreference.Hedging:BSONEncodable, BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.DocumentEncoder<BSON.Key>)
    {
        bson["enabled"] = self == .enabled
    }
}
