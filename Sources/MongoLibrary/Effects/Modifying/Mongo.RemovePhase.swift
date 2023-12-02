import BSON

extension Mongo
{
    @frozen public
    enum RemovePhase:Equatable, Hashable, Sendable
    {
        case deleted
    }
}
extension Mongo.RemovePhase:BSONEncodable
{
    @inlinable public
    func encode(to field:inout BSON.Field)
    {
        (true).encode(to: &field)
    }
}
extension Mongo.RemovePhase:MongoModificationPhase
{
    @inlinable public static
    var field:BSON.Key { "remove" }
}
