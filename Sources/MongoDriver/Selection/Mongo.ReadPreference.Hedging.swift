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
extension Mongo.ReadPreference.Hedging:BSONDocumentEncodable
{
    public
    func encode(to bson:inout BSON.Fields)
    {
        bson["enabled"] = self == .enabled
    }
}
